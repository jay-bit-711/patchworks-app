from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Job
from .permissions import IsAdminOrSuperAdmin
from .serializers import EvidenceSerializer, JobSerializer, RatingSerializer, UserSerializer

User = get_user_model()


class AuthSyncView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)


class JobViewSet(viewsets.ModelViewSet):
    serializer_class = JobSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role in {"admin", "superadmin"}:
            return Job.objects.all().order_by("-created_at")
        if user.role == "mestri":
            return Job.objects.filter(assigned_mestri=user).order_by("-created_at")
        return Job.objects.filter(user=user).order_by("-created_at")

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def partial_update(self, request, *args, **kwargs):
        instance = self.get_object()
        user = request.user
        if user.role not in {"admin", "superadmin"} and user not in {instance.user, instance.assigned_mestri}:
            return Response({"detail": "Not allowed."}, status=status.HTTP_403_FORBIDDEN)
        return super().partial_update(request, *args, **kwargs)

    @action(detail=True, methods=["post"])
    def accept(self, request, pk=None):
        job = get_object_or_404(Job, id=pk)
        if request.user.role != "mestri":
            return Response({"detail": "Only mestri can accept jobs."}, status=status.HTTP_403_FORBIDDEN)
        if job.assigned_mestri and job.assigned_mestri != request.user:
            return Response({"detail": "Job already assigned."}, status=status.HTTP_400_BAD_REQUEST)

        job.assigned_mestri = request.user
        if job.status == "pending":
            job.status = "in_progress"
        job.save(update_fields=["assigned_mestri", "status"])
        return Response(JobSerializer(job, context={"request": request}).data)

    @action(detail=True, methods=["post"], permission_classes=[IsAuthenticated, IsAdminOrSuperAdmin])
    def assign(self, request, pk=None):
        job = self.get_object()
        mestri_id = request.data.get("mestri_id")
        if not mestri_id:
            return Response({"detail": "mestri_id is required."}, status=status.HTTP_400_BAD_REQUEST)

        mestri = get_object_or_404(User, id=mestri_id, role="mestri")
        job.assigned_mestri = mestri
        if job.status == "pending":
            job.status = "in_progress"
        job.save(update_fields=["assigned_mestri", "status"])
        return Response(JobSerializer(job, context={"request": request}).data)

    @action(detail=True, methods=["get", "post"], url_path="evidences")
    def evidences(self, request, pk=None):
        job = self.get_object()

        if request.method == "GET":
            data = EvidenceSerializer(job.evidences.order_by("-timestamp"), many=True).data
            return Response(data)

        serializer = EvidenceSerializer(data=request.data, context={"request": request, "job": job})
        serializer.is_valid(raise_exception=True)
        evidence = serializer.save()
        return Response(EvidenceSerializer(evidence).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"], url_path="rate")
    def rate(self, request, pk=None):
        job = self.get_object()
        serializer = RatingSerializer(data=request.data, context={"request": request, "job": job})
        serializer.is_valid(raise_exception=True)
        rating = serializer.save()
        return Response(RatingSerializer(rating).data, status=status.HTTP_201_CREATED)


class AdminUserViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.all().order_by("id")
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated, IsAdminOrSuperAdmin]

    @action(detail=True, methods=["post"])
    def upgrade(self, request, pk=None):
        user = self.get_object()
        role = request.data.get("role")
        if role not in {"homeowner", "mestri", "admin", "superadmin"}:
            return Response({"detail": "Invalid role."}, status=status.HTTP_400_BAD_REQUEST)

        if role == "superadmin" and request.user.role != "superadmin":
            return Response({"detail": "Only superadmin can create superadmin."}, status=status.HTTP_403_FORBIDDEN)

        user.role = role
        user.save(update_fields=["role"])
        return Response(UserSerializer(user).data)
