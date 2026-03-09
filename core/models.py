from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.db import models
from django.utils import timezone
from django.utils.translation import gettext_lazy as _
import hashlib
import os

from .firebase import get_bucket

class User(AbstractUser):
    ROLE_CHOICES = (
        ('homeowner', 'Home Owner'),
        ('admin', 'Admin'),
        ('builder', 'Builder'),
        ('superadmin', 'Super Admin'),
    )
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='homeowner')
    MESTRI_REQUEST_CHOICES = (
        ("none", "No Request"),
        ("pending", "Pending"),
        ("approved", "Approved"),
        ("rejected", "Rejected"),
    )
    mestri_request_status = models.CharField(max_length=10, choices=MESTRI_REQUEST_CHOICES, default="none")
    mestri_requested_at = models.DateTimeField(null=True, blank=True)
    mestri_reviewed_at = models.DateTimeField(null=True, blank=True)
    mestri_reapply_after = models.DateTimeField(null=True, blank=True)
    mestri_reject_reason = models.CharField(max_length=255, blank=True)
    phone = models.CharField(max_length=15, blank=True, help_text=_('+91 prefix recommended'))
    address = models.CharField(max_length=255, blank=True, help_text=_('Preferred service address'))
    pii_name_hash = models.CharField(max_length=64, blank=True)
    pii_email_hash = models.CharField(max_length=64, blank=True)
    pii_phone_hash = models.CharField(max_length=64, blank=True)
    pii_address_hash = models.CharField(max_length=64, blank=True)

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

    def save(self, *args, **kwargs):
        salt = os.getenv("PII_HASH_SALT", "patchworks-dev-salt")

        def _h(value):
            if not value:
                return ""
            payload = f"{salt}:{value.strip().lower()}".encode("utf-8")
            return hashlib.sha256(payload).hexdigest()

        self.pii_name_hash = _h(self.first_name or self.username)
        self.pii_email_hash = _h(self.email)
        self.pii_phone_hash = _h(self.phone)
        self.pii_address_hash = _h(self.address)
        super().save(*args, **kwargs)

    def upgrade_role(self, new_role, upgrader):
        if upgrader.role not in ['admin', 'superadmin']:
            raise ValidationError("Only admins/superadmins can upgrade roles.")
        if new_role == 'superadmin' and upgrader.role != 'superadmin':
            raise ValidationError("Only superadmin can create superadmins.")
        self.role = new_role
        self.save()


class Job(models.Model):
    MATERIAL_CHOICES = (
        ("with", "With Material"),
        ("without", "Without Material"),
    )
    QUOTE_STATUS_CHOICES = (
        ("pending", "Pending"),
        ("accepted", "Accepted"),
        ("rejected", "Rejected"),
    )
    PAYMENT_STATUS_CHOICES = (
        ("pending", "Pending"),
        ("paid", "Paid"),
        ("later", "Pay Later"),
    )
    STATUS_CHOICES = (
        ('created', 'Created'),
        ('quoted', 'Quoted'),
        ('assigned', 'Assigned'),
        ('started', 'Started'),
        ('done', 'Done'),
        ('rejected', 'Rejected'),
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='jobs')
    description = models.TextField(blank=True, help_text='One-liner problem description')
    location = models.CharField(max_length=255, blank=True, help_text='Text or GPS pin')
    location_hash = models.CharField(max_length=64, blank=True)
    material_choice = models.CharField(max_length=10, choices=MATERIAL_CHOICES, default="without")
    quote_amount = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    quote_time_days = models.PositiveIntegerField(default=0)
    quote_time_hours = models.PositiveIntegerField(default=0)
    quote_status = models.CharField(max_length=10, choices=QUOTE_STATUS_CHOICES, default="pending")
    quote_seen_at = models.DateTimeField(null=True, blank=True)
    payment_status = models.CharField(max_length=10, choices=PAYMENT_STATUS_CHOICES, default="pending")
    payment_reference = models.CharField(max_length=100, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='created')
    assigned_mestri = models.ForeignKey(
        User,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='assigned_jobs',
        limit_choices_to={'role': 'builder'}
    )
    admin_seen_at = models.DateTimeField(null=True, blank=True)
    started_at = models.DateTimeField(null=True, blank=True)
    done_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    def clean(self):
        if not self.pk:
            today = timezone.localdate()
            jobs_today = Job.objects.filter(user=self.user, created_at__date=today).count()
            if jobs_today >= 8:
                raise ValidationError("User cannot create more than 8 jobs in a day.")

    def save(self, *args, **kwargs):
        salt = os.getenv("PII_HASH_SALT", "patchworks-dev-salt")
        if self.location:
            payload = f"{salt}:{self.location.strip().lower()}".encode("utf-8")
            self.location_hash = hashlib.sha256(payload).hexdigest()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Job {self.id} - {self.user} - {self.status}"


class Evidence(models.Model):
    job = models.ForeignKey(Job, on_delete=models.CASCADE, related_name='evidences')
    file = models.FileField(upload_to='evidences/%Y/%m/%d/', max_length=500, blank=True, null=True)
    file_url = models.URLField(max_length=1000, blank=True)
    uploaded_by = models.ForeignKey(
        User,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='uploaded_evidences',
    )
    file_size = models.PositiveIntegerField(default=0)
    timestamp = models.DateTimeField(default=timezone.now)
    is_before = models.BooleanField(default=True)

    def clean(self):
        if not self.pk and self.job.evidences.count() >= 4:
            raise ValidationError("Maximum 4 evidences allowed per job.")
        if self.file and self.file.size > 50 * 1024 * 1024:
            raise ValidationError("File size exceeds 50MB.")

    def save(self, *args, **kwargs):
        print("Evidence.save() started")

        if self.file and not self.file_url:
            print("Firebase block entered")
            try:
                # Read file content before Django/file handling can close the pointer.
                self.file.open("rb")
                file_content = self.file.read()
                print("Read file content, size:", len(file_content))

                bucket = get_bucket()
                if bucket is None:
                    raise RuntimeError(
                        "Firebase bucket is unavailable. Check ENABLE_FIREBASE_STORAGE=1 and Firebase credentials."
                    )
                print("Bucket:", bucket.name)

                import mimetypes
                from io import BytesIO

                file_name = os.path.basename(self.file.name)
                timestamp_str = self.timestamp.strftime("%Y%m%d_%H%M%S")
                blob_path = f"evidences/{self.job.id}/{timestamp_str}_{file_name}"
                print("Uploading to:", blob_path)

                blob = bucket.blob(blob_path)
                content_type = getattr(self, "_temp_content_type", None)
                if not content_type:
                    guessed_type, _ = mimetypes.guess_type(file_name)
                    content_type = guessed_type or "application/octet-stream"
                print("Content-Type:", content_type)

                file_obj = BytesIO(file_content)
                blob.upload_from_file(file_obj, content_type=content_type)

                blob.make_public()
                self.file_url = blob.public_url
                print("Upload success")
                print("Public URL set:", self.file_url)

                self.file_size = len(file_content)
                print("File size updated:", self.file_size)

                # Optional: remove local file after successful Firebase upload.
                # if self.file and self.file.storage.exists(self.file.name):
                #     self.file.storage.delete(self.file.name)
            except Exception as e:
                print("Firebase upload failed:", str(e))
                import traceback
                traceback.print_exc()
                raise

        super().save(*args, **kwargs)
        print("Evidence.save() END")

    def __str__(self):
        return f"Evidence for Job {self.job.id} - {'Before' if self.is_before else 'After'} - {self.file_url or 'no URL'}"


class Rating(models.Model):
    RATING_CHOICES = (
        ('like', 'Like 👍'),
        ('dislike', 'Dislike 👎'),
    )
    job = models.ForeignKey(Job, on_delete=models.CASCADE, related_name='ratings')
    rated_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='given_ratings')
    rated_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_ratings')
    rating = models.CharField(max_length=10, choices=RATING_CHOICES, default='like')
    comments = models.TextField(blank=True, help_text='Optional remarks')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.rated_by} rated {self.rated_user} {self.rating} on Job {self.job.id}"

    class Meta:
        unique_together = ('job', 'rated_by')


class Interest(models.Model):
    AREA_CHOICES = (
        ("store", "Store"),
        ("portfolios", "Portfolios"),
        ("contact", "Contact"),
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="interests")
    area = models.CharField(max_length=20, choices=AREA_CHOICES)
    message = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user} interest in {self.area}"
