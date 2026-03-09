from django.contrib.auth import get_user_model
from django.utils.dateparse import parse_datetime
from django.utils import timezone
from django.utils.timezone import is_naive, make_aware
import re
from rest_framework import serializers

from .models import Evidence, Interest, Job, Rating

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    role_key = serializers.SerializerMethodField()
    role_display = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            "id",
            "email",
            "username",
            "first_name",
            "role",
            "role_key",
            "role_display",
            "phone",
            "address",
            "mestri_request_status",
            "mestri_requested_at",
            "mestri_reviewed_at",
            "mestri_reapply_after",
            "mestri_reject_reason",
        ]

    def get_role_key(self, obj):
        if obj.is_superuser:
            return "superadmin"
        if obj.is_staff:
            return "admin"
        if obj.role in {"admin", "superadmin", "builder", "homeowner"}:
            return obj.role
        return "homeowner"

    def get_role_display(self, obj):
        role_key = self.get_role_key(obj)
        labels = {
            "homeowner": "Home Owner",
            "admin": "Supervisor",
            "builder": "Builder",
            "superadmin": "Supervisor Admin",
        }
        return labels.get(role_key, "Homeowner")


class EvidenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Evidence
        fields = ["id", "job", "file", "file_url", "file_size", "timestamp", "is_before"]
        read_only_fields = ["id", "job", "file_url", "file_size", "timestamp"]

    def validate(self, attrs):
        job = self.context["job"]
        request = self.context["request"]
        file_obj = attrs.get("file")
        is_before = attrs.get("is_before", True)

        if job.evidences.count() >= 4:
            raise serializers.ValidationError("Maximum 4 evidences allowed per job.")

        can_upload = request.user == job.user or request.user == job.assigned_mestri
        if not can_upload:
            raise serializers.ValidationError("You cannot upload evidence for this job.")

        if file_obj is None:
            raise serializers.ValidationError("file is required.")

        if file_obj.size > 50 * 1024 * 1024:
            raise serializers.ValidationError("File size exceeds 50MB.")

        uploader_role = request.user.role
        if job.evidences.filter(is_before=is_before, uploaded_by=request.user).exists():
            evidence_type = "before" if is_before else "after"
            raise serializers.ValidationError(f"{evidence_type.title()} evidence already exists for {uploader_role}.")

        if uploader_role == "homeowner" and not is_before:
            homeowner_before_exists = job.evidences.filter(is_before=True, uploaded_by=job.user).exists()
            if not homeowner_before_exists:
                raise serializers.ValidationError("Homeowner before evidence is required before after upload.")
        elif request.user == job.assigned_mestri and job.status != "started":
            raise serializers.ValidationError("Builder/Supervisor evidence upload is allowed only after job is started.")

        return attrs

    def create(self, validated_data):
        validated_data["job"] = self.context["job"]
        validated_data["uploaded_by"] = self.context["request"].user
        file_obj = validated_data.get("file")
        content_type = getattr(file_obj, "content_type", None)
        captured_at = self.context["request"].data.get("captured_at")
        if captured_at:
            parsed = parse_datetime(captured_at)
            if parsed is not None:
                if is_naive(parsed):
                    parsed = make_aware(parsed, timezone.get_current_timezone())
                validated_data["timestamp"] = parsed
        evidence = Evidence(**validated_data)
        if content_type:
            evidence._temp_content_type = content_type
        evidence.save()
        return evidence


class JobSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    assigned_mestri = UserSerializer(read_only=True)
    assigned_mestri_id = serializers.IntegerField(write_only=True, required=False)
    title = serializers.CharField(write_only=True, required=False, max_length=50)
    work_type = serializers.CharField(write_only=True, required=False, allow_blank=True)
    appointment_at = serializers.DateTimeField(write_only=True, required=False, allow_null=True)
    material_choice = serializers.ChoiceField(choices=Job.MATERIAL_CHOICES, required=False)
    evidences = EvidenceSerializer(many=True, read_only=True)
    display_title = serializers.SerializerMethodField()
    before_preview_url = serializers.SerializerMethodField()
    status_label = serializers.SerializerMethodField()
    has_rated = serializers.SerializerMethodField()
    my_rating = serializers.SerializerMethodField()
    homeowner_before_uploaded = serializers.SerializerMethodField()
    homeowner_after_uploaded = serializers.SerializerMethodField()
    mestri_before_uploaded = serializers.SerializerMethodField()
    mestri_after_uploaded = serializers.SerializerMethodField()

    class Meta:
        model = Job
        fields = [
            "id",
            "user",
            "description",
            "display_title",
            "before_preview_url",
            "location",
            "status",
            "status_label",
            "has_rated",
            "my_rating",
            "homeowner_before_uploaded",
            "homeowner_after_uploaded",
            "mestri_before_uploaded",
            "mestri_after_uploaded",
            "assigned_mestri",
            "assigned_mestri_id",
            "material_choice",
            "quote_amount",
            "quote_time_days",
            "quote_time_hours",
            "quote_status",
            "quote_seen_at",
            "payment_status",
            "payment_reference",
            "admin_seen_at",
            "started_at",
            "done_at",
            "title",
            "work_type",
            "appointment_at",
            "created_at",
            "completed_at",
            "evidences",
        ]
        read_only_fields = [
            "id",
            "created_at",
            "completed_at",
            "user",
            "assigned_mestri",
            "evidences",
            "admin_seen_at",
            "quote_seen_at",
            "started_at",
            "done_at",
            "payment_reference",
        ]

    def validate(self, attrs):
        request = self.context["request"]
        user = request.user

        if self.instance is None:
            phone_digits = "".join(ch for ch in (user.phone or "") if ch.isdigit())
            if not user.phone or len(phone_digits) < 10:
                raise serializers.ValidationError("Add phone first.")
            today = timezone.localdate()
            jobs_today = user.jobs.filter(created_at__date=today).count()
            if jobs_today >= 8:
                raise serializers.ValidationError("User cannot create more than 8 jobs in a day.")

        mestri_id = attrs.get("assigned_mestri_id")
        if mestri_id is not None:
            if user.role not in {"admin", "superadmin"}:
                raise serializers.ValidationError("Only admin/superadmin can assign builder.")
            try:
                mestri = User.objects.get(id=mestri_id)
            except User.DoesNotExist as exc:
                raise serializers.ValidationError("assigned_mestri_id must be a valid user.") from exc
            if mestri.role not in {"builder", "admin", "superadmin"}:
                raise serializers.ValidationError("assigned_mestri_id must be builder/admin/superadmin.")
            attrs["_mestri"] = mestri

        title = (attrs.get("title") or "").strip()
        description = (attrs.get("description") or "").strip()
        pii_pattern = re.compile(r"(\b\d{10,}\b|@|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})")
        if pii_pattern.search(title) or pii_pattern.search(description):
            raise serializers.ValidationError("Do not include phone/email in title or description.")

        return attrs

    def create(self, validated_data):
        validated_data.pop("assigned_mestri_id", None)
        title = validated_data.pop("title", "").strip()
        work_type = validated_data.pop("work_type", "").strip()
        appointment_at = validated_data.pop("appointment_at", None)
        mestri = validated_data.pop("_mestri", None)
        validated_data["user"] = self.context["request"].user
        if title:
            normalized = title
        else:
            normalized = validated_data.get("description", "").strip()
        if work_type:
            normalized = f"[{work_type}] {normalized}".strip()
        if appointment_at:
            normalized = f"{normalized} | Appointment: {appointment_at.isoformat()}".strip()
        validated_data["description"] = normalized
        if mestri:
            validated_data["assigned_mestri"] = mestri
        return super().create(validated_data)

    def update(self, instance, validated_data):
        validated_data.pop("assigned_mestri_id", None)
        mestri = validated_data.pop("_mestri", None)
        if mestri:
            instance.assigned_mestri = mestri

        status = validated_data.get("status")
        if status == "done" and instance.completed_at is None:
            from django.utils import timezone

            instance.completed_at = timezone.now()
            instance.done_at = timezone.now()

        return super().update(instance, validated_data)

    def get_display_title(self, obj):
        description = (obj.description or "").strip()
        if description.startswith("[") and "]" in description:
            description = description.split("]", 1)[1].strip()
        if " | Appointment:" in description:
            description = description.split(" | Appointment:", 1)[0].strip()
        return description or "Untitled job"

    def get_before_preview_url(self, obj):
        before = obj.evidences.filter(is_before=True).order_by("-timestamp").first()
        return before.file_url if before else ""

    def get_status_label(self, obj):
        labels = {
            "created": "Created",
            "quoted": "Quoted",
            "assigned": "Assigned",
            "started": "Started",
            "done": "Done",
            "rejected": "Rejected",
        }
        return labels.get(obj.status, "Created")

    def get_has_rated(self, obj):
        request = self.context.get("request")
        user = getattr(request, "user", None)
        if not user or not user.is_authenticated:
            return False
        return obj.ratings.filter(rated_by=user).exists()

    def get_homeowner_before_uploaded(self, obj):
        return obj.evidences.filter(is_before=True, uploaded_by=obj.user).exists()

    def get_my_rating(self, obj):
        request = self.context.get("request")
        user = getattr(request, "user", None)
        if not user or not user.is_authenticated:
            return None
        rating = obj.ratings.filter(rated_by=user).order_by("-created_at").first()
        if not rating:
            return None
        return {
            "rating": rating.rating,
            "comments": rating.comments or "",
            "created_at": rating.created_at,
        }

    def get_homeowner_after_uploaded(self, obj):
        return obj.evidences.filter(is_before=False, uploaded_by=obj.user).exists()

    def get_mestri_before_uploaded(self, obj):
        if not obj.assigned_mestri_id:
            return False
        return obj.evidences.filter(is_before=True, uploaded_by=obj.assigned_mestri).exists()

    def get_mestri_after_uploaded(self, obj):
        if not obj.assigned_mestri_id:
            return False
        return obj.evidences.filter(is_before=False, uploaded_by=obj.assigned_mestri).exists()


class RatingSerializer(serializers.ModelSerializer):
    rated_by = UserSerializer(read_only=True)
    rated_user = UserSerializer(read_only=True)

    class Meta:
        model = Rating
        fields = ["id", "job", "rated_by", "rated_user", "rating", "comments", "created_at"]
        read_only_fields = ["id", "job", "rated_by", "rated_user", "created_at"]

    def validate(self, attrs):
        job = self.context["job"]
        user = self.context["request"].user

        if Rating.objects.filter(job=job, rated_by=user).exists():
            raise serializers.ValidationError("You have already submitted a rating for this job.")

        if job.status != "done":
            raise serializers.ValidationError("Rating is allowed only when job is done.")

        comments = (attrs.get("comments") or "").strip()
        pii_pattern = re.compile(r"(\b\d{10,}\b|@|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})")
        if comments and pii_pattern.search(comments):
            raise serializers.ValidationError("Do not include phone/email in ratings comments.")

        if not job.assigned_mestri:
            raise serializers.ValidationError("Cannot rate without assigned builder.")

        if user == job.user:
            attrs["_rated_user"] = job.assigned_mestri
        elif user == job.assigned_mestri:
            attrs["_rated_user"] = job.user
        elif user.role in {"admin", "superadmin"}:
            rated_user_id = self.context["request"].data.get("rated_user_id")
            if not rated_user_id:
                raise serializers.ValidationError("rated_user_id is required for admin rating.")
            try:
                attrs["_rated_user"] = User.objects.get(id=rated_user_id)
            except User.DoesNotExist as exc:
                raise serializers.ValidationError("rated_user_id is invalid.") from exc
        else:
            raise serializers.ValidationError("Only job owner or assigned builder can rate this job.")

        return attrs

    def create(self, validated_data):
        job = self.context["job"]
        rated_user = validated_data.pop("_rated_user")
        return Rating.objects.create(
            job=job,
            rated_by=self.context["request"].user,
            rated_user=rated_user,
            rating=validated_data["rating"],
            comments=validated_data.get("comments", ""),
        )


class InterestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Interest
        fields = ["id", "area", "message", "created_at"]
        read_only_fields = ["id", "created_at"]
