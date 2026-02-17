from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.db import models
from django.utils import timezone
from django.utils.translation import gettext_lazy as _
import os

from .firebase import get_bucket

class User(AbstractUser):
    ROLE_CHOICES = (
        ('homeowner', 'Home Owner'),
        ('admin', 'Admin'),
        ('mestri', 'Mestri/Plumber'),
        ('superadmin', 'Super Admin'),
    )
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='homeowner')
    phone = models.CharField(max_length=15, blank=True, help_text=_('+91 prefix recommended'))

    # Optional: Firebase UID after SSO
    firebase_uid = models.CharField(max_length=128, blank=True, null=True)

    groups = models.ManyToManyField(
        'auth.Group',
        related_name='custom_user_groups',
        blank=True,
        help_text=_('The groups this user belongs to. A user will get all permissions granted to each of their groups.'),
        verbose_name=_('groups'),
    )

    user_permissions = models.ManyToManyField(
        'auth.Permission',
        related_name='custom_user_permissions',
        blank=True,
        help_text=_('Specific permissions for this user.'),
        verbose_name=_('user permissions'),
    )

    def __str__(self):
        return self.email or self.username

    def upgrade_role(self, new_role, upgrader):
        if upgrader.role not in ['admin', 'superadmin']:
            raise ValidationError("Only admins/superadmins can upgrade roles.")
        if new_role == 'superadmin' and upgrader.role != 'superadmin':
            raise ValidationError("Only superadmin can create superadmins.")
        self.role = new_role
        self.save()


class Job(models.Model):
    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('in_progress', 'In Progress'),
        ('done', 'Done'),
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='jobs')
    description = models.TextField(blank=True, help_text='One-liner problem description')
    location = models.CharField(max_length=255, blank=True, help_text='Text or GPS pin')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    assigned_mestri = models.ForeignKey(
        User,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='assigned_jobs',
        limit_choices_to={'role': 'mestri'}
    )
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    def clean(self):
        if not self.pk and self.user.jobs.count() >= 8:
            raise ValidationError("User cannot create more than 8 jobs.")

    def __str__(self):
        return f"Job {self.id} - {self.user} - {self.status}"


class Evidence(models.Model):
    job = models.ForeignKey(Job, on_delete=models.CASCADE, related_name='evidences')
    file = models.FileField(upload_to='evidences/%Y/%m/%d/', max_length=500, blank=True, null=True)
    file_url = models.URLField(max_length=1000, blank=True)
    file_size = models.PositiveIntegerField(default=0)
    timestamp = models.DateTimeField(default=timezone.now)
    is_before = models.BooleanField(default=True)

    def clean(self):
        if not self.pk and self.job.evidences.count() >= 2:
            raise ValidationError("Maximum 2 evidences allowed per job.")
        if self.file and self.file.size > 50 * 1024 * 1024:
            raise ValidationError("File size exceeds 50MB.")

    def save(self, *args, **kwargs):
        self.full_clean()
        if self.file and not self.file_url:
            bucket = get_bucket()
            if bucket is not None:
                file_name = os.path.basename(self.file.name)
                timestamp_str = self.timestamp.strftime("%Y%m%d_%H%M%S")
                blob_path = f"evidences/{self.job.id}/{timestamp_str}_{file_name}"
                blob = bucket.blob(blob_path)
                self.file.seek(0)
                content_type = getattr(self.file, "content_type", None) or "application/octet-stream"
                blob.upload_from_file(self.file.file, content_type=content_type)
                blob.make_public()
                self.file_url = blob.public_url
            self.file_size = self.file.size

        super().save(*args, **kwargs)

    def __str__(self):
        return f"Evidence for Job {self.job.id} - {'Before' if self.is_before else 'After'} - {self.file_url or 'no URL'}"


class Rating(models.Model):
    RATING_CHOICES = (
        ('like', 'Like 👍'),
        ('dislike', 'Dislike 👎'),
    )
    job = models.OneToOneField(Job, on_delete=models.CASCADE, related_name='rating')
    rated_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='given_ratings')
    rated_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_ratings')
    rating = models.CharField(max_length=10, choices=RATING_CHOICES, default='like')
    comments = models.TextField(blank=True, help_text='Optional remarks')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.rated_by} rated {self.rated_user} {self.rating} on Job {self.job.id}"

    class Meta:
        unique_together = ('job', 'rated_by')
