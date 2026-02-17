from django.contrib.auth import get_user_model
from rest_framework import serializers

from .models import Evidence, Job, Rating

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "email", "username", "role", "phone"]


class EvidenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Evidence
        fields = ["id", "job", "file", "file_url", "file_size", "timestamp", "is_before"]
        read_only_fields = ["id", "job", "file_url", "file_size", "timestamp"]

    def validate(self, attrs):
        job = self.context["job"]
        request = self.context["request"]
        file_obj = attrs.get("file")

        if job.evidences.count() >= 2:
            raise serializers.ValidationError("Maximum 2 evidences allowed per job.")

        can_upload = request.user == job.user or request.user == job.assigned_mestri or request.user.role in {"admin", "superadmin"}
        if not can_upload:
            raise serializers.ValidationError("You cannot upload evidence for this job.")

        if file_obj is None:
            raise serializers.ValidationError("file is required.")

        if file_obj.size > 50 * 1024 * 1024:
            raise serializers.ValidationError("File size exceeds 50MB.")

        return attrs

    def create(self, validated_data):
        validated_data["job"] = self.context["job"]
        return super().create(validated_data)


class JobSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    assigned_mestri = UserSerializer(read_only=True)
    assigned_mestri_id = serializers.IntegerField(write_only=True, required=False)
    evidences = EvidenceSerializer(many=True, read_only=True)

    class Meta:
        model = Job
        fields = [
            "id",
            "user",
            "description",
            "location",
            "status",
            "assigned_mestri",
            "assigned_mestri_id",
            "created_at",
            "completed_at",
            "evidences",
        ]
        read_only_fields = ["id", "created_at", "completed_at", "user", "assigned_mestri", "evidences"]

    def validate(self, attrs):
        request = self.context["request"]
        user = request.user

        if self.instance is None and user.jobs.count() >= 8:
            raise serializers.ValidationError("User cannot create more than 8 jobs.")

        mestri_id = attrs.get("assigned_mestri_id")
        if mestri_id is not None:
            if user.role not in {"admin", "superadmin"}:
                raise serializers.ValidationError("Only admin/superadmin can assign mestri.")
            try:
                mestri = User.objects.get(id=mestri_id, role="mestri")
            except User.DoesNotExist as exc:
                raise serializers.ValidationError("assigned_mestri_id must be a valid mestri user.") from exc
            attrs["_mestri"] = mestri

        return attrs

    def create(self, validated_data):
        validated_data.pop("assigned_mestri_id", None)
        mestri = validated_data.pop("_mestri", None)
        validated_data["user"] = self.context["request"].user
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

        return super().update(instance, validated_data)


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

        if job.status != "done":
            raise serializers.ValidationError("Rating is allowed only when job is done.")

        if user != job.user and user.role not in {"admin", "superadmin"}:
            raise serializers.ValidationError("Only job owner can rate for this job.")

        if not job.assigned_mestri:
            raise serializers.ValidationError("Cannot rate without assigned mestri.")

        return attrs

    def create(self, validated_data):
        job = self.context["job"]
        rating, _ = Rating.objects.update_or_create(
            job=job,
            rated_by=self.context["request"].user,
            defaults={
                "rated_user": job.assigned_mestri,
                "rating": validated_data["rating"],
                "comments": validated_data.get("comments", ""),
            },
        )
        return rating
