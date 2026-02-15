# core/models.py

from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

class User(AbstractUser):
    ROLE_CHOICES = (
        ('homeowner', 'Home Owner'),
        ('admin', 'Admin'),
        ('mestri', 'Mestri/Plumber'),
        ('superadmin', 'Super Admin'),
    )
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='homeowner')
    phone = models.CharField(max_length=15, blank=True, help_text=_('+91 prefix recommended'))

    # Optional: Link to Firebase UID after SSO
    firebase_uid = models.CharField(max_length=128, blank=True, null=True)

    # Override groups and user_permissions to set custom related_name (this fixes the clash)
    groups = models.ManyToManyField(
        'auth.Group',
        related_name='custom_user_groups',  # Unique name to avoid clash with default User
        blank=True,
        help_text=_(
            'The groups this user belongs to. A user will get all permissions '
            'granted to each of their groups.'
        ),
        verbose_name=_('groups'),
    )

    user_permissions = models.ManyToManyField(
        'auth.Permission',
        related_name='custom_user_permissions',  # Unique name to avoid clash
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
        # Guard rail: Max 8 jobs per user (active or total for MVP)
        if not self.pk:  # New job only
            if self.user.jobs.count() >= 8:
                raise ValidationError("User cannot create more than 8 jobs.")

    def __str__(self):
        return f"Job {self.id} - {self.user} - {self.status}"

class Evidence(models.Model):
    job = models.ForeignKey(Job, on_delete=models.CASCADE, related_name='evidences')
    file_url = models.URLField(max_length=500, blank=False)  # We'll store Firebase Storage URL
    timestamp = models.DateTimeField(default=timezone.now)
    is_before = models.BooleanField(default=True)  # True = before, False = after

    def clean(self):
        # Guard rail: Max 2 per job
        if not self.pk:
            if self.job.evidences.count() >= 2:
                raise ValidationError("Maximum 2 evidences allowed per job.")
        # Size check happens in view/upload logic (since file_url is URL)

    def __str__(self):
        return f"Evidence for Job {self.job.id} - {'Before' if self.is_before else 'After'}"