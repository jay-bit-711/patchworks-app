from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from django.utils import timezone
from datetime import timedelta
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Interest, Job
from .permissions import IsAdminOrSuperAdmin
from .serializers import EvidenceSerializer, InterestSerializer, JobSerializer, RatingSerializer, UserSerializer

User = get_user_model()


def _resolved_role(user):
    if user.is_superuser:
        return "superadmin"
    if user.is_staff:
        return "admin"
    if user.role in {"homeowner", "builder", "admin", "superadmin"}:
        return user.role
    return "homeowner"
@action(detail=True, methods=["post"], permission_classes=[IsAuthenticated, IsAdminOrSuperAdmin])
def assign(self, request, pk=None):
    job = self.get_object()
    builder_id = request.data.get("builder_id") or request.data.get("mestri_id")
    if not builder_id:
        return Response({"detail": "builder_id is required."}, status=status.HTTP_400_BAD_REQUEST)
    mestri = get_object_or_404(User, id=builder_id)
    if mestri.role not in {"builder", "admin", "superadmin"}:
        return Response({"detail": "Assignee must be builder/admin/superadmin."}, status=status.HTTP_400_BAD_REQUEST)
    job.assigned_mestri = mestri
    if job.status in {"created", "quoted"}:
        job.status = "assigned"
    job.save(update_fields=["assigned_mestri", "status"])
    return Response(JobSerializer(job, context={"request": request}).data)
@action(detail=True, methods=["post"], permission_classes=[IsAuthenticated, IsAdminOrSuperAdmin], url_path="review-builder")
def review_builder(self, request, pk=None):
    # ...
    if decision == "approve":
        # ...
        if user.role not in {"admin", "superadmin"}:
            user.role = "builder"
    # ...

class BuilderRequestView(APIView):
    permission_classes = [IsAuthenticated]
    # ...

class MestriRequestView(BuilderRequestView):
    """Backward-compatible alias for legacy clients."""

class AuthSyncView(APIView):
    permission_classes = [IsAuthenticated]

    def _enforce_staff_role(self, user):
        expected_role = _resolved_role(user)
        if user.role != expected_role:
            user.role = expected_role
            user.save(update_fields=["role"])

    def get(self, request):
        self._enforce_staff_role(request.user)
        return Response(UserSerializer(request.user).data)

    def patch(self, request):
        phone = (request.data.get("phone") or "").strip()
        first_name = (request.data.get("first_name") or "").strip()
        username = (request.data.get("username") or "").strip()
        email = (request.data.get("email") or "").strip()
        address = (request.data.get("address") or "").strip()

        updated_fields = []

        if phone:
            digits = "".join(ch for ch in phone if ch.isdigit())
            if len(digits) == 12 and digits.startswith("91"):
                normalized = f"+{digits}"
            elif len(digits) == 10:
                normalized = f"+91{digits}"
            else:
                return Response({"detail": "Enter valid 10-digit phone number."}, status=status.HTTP_400_BAD_REQUEST)
            request.user.phone = normalized
            updated_fields.append("phone")

        if first_name:
            request.user.first_name = first_name[:50]
            updated_fields.append("first_name")

        if username:
            request.user.username = username[:150]
            updated_fields.append("username")

        if email:
            request.user.email = email[:254]
            updated_fields.append("email")

        if "address" in request.data:
            request.user.address = address[:255]
            updated_fields.append("address")

        self._enforce_staff_role(request.user)
        if not updated_fields:
            return Response(UserSerializer(request.user).data)

        request.user.save(update_fields=list(dict.fromkeys(updated_fields)))
        return Response(UserSerializer(request.user).data)


class JobViewSet(viewsets.ModelViewSet):
    serializer_class = JobSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        role = _resolved_role(user)
        mode = (self.request.query_params.get("mode") or "").strip().lower()
        if mode == "homeowner":
            return Job.objects.filter(user=user).order_by("-created_at")
        if mode == "builder":
            if role in {"admin", "superadmin"}:
                return Job.objects.filter(assigned_mestri=user).order_by("-created_at")
            return Job.objects.filter(assigned_mestri=user).order_by("-created_at")
        if role in {"admin", "superadmin"}:
            return Job.objects.all().order_by("-created_at")
        if role == "builder":
            return Job.objects.filter(assigned_mestri=user).order_by("-created_at")
        return Job.objects.filter(user=user).order_by("-created_at")

    def list(self, request, *args, **kwargs):
        response = super().list(request, *args, **kwargs)
        if request.user.role in {"admin", "superadmin"}:
            Job.objects.filter(admin_seen_at__isnull=True).update(admin_seen_at=timezone.now())
        return response

    def retrieve(self, request, *args, **kwargs):
        response = super().retrieve(request, *args, **kwargs)
        job = self.get_object()
        if request.user.role in {"admin", "superadmin"} and job.admin_seen_at is None:
            job.admin_seen_at = timezone.now()
            job.save(update_fields=["admin_seen_at"])
        if request.user == job.user and job.quote_amount is not None and job.quote_seen_at is None:
            job.quote_seen_at = timezone.now()
            job.save(update_fields=["quote_seen_at"])
        return response

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def partial_update(self, request, *args, **kwargs):
        instance = self.get_object()
        user = request.user
        if user.role not in {"admin", "superadmin"} and user not in {instance.user, instance.assigned_mestri}:
            return Response({"detail": "Not allowed."}, status=status.HTTP_403_FORBIDDEN)

        requested_status = request.data.get("status")
        if requested_status == "done" and user.role == "builder":
            has_mestri_after = instance.evidences.filter(is_before=False, uploaded_by=user).exists()
            if not has_mestri_after:
                return Response(
                    {"detail": "Builder after evidence is required before marking job done."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
        return super().partial_update(request, *args, **kwargs)

    @action(detail=True, methods=["post"])
    def accept(self, request, pk=None):
        job = get_object_or_404(Job, id=pk)
        if request.user != job.user:
            return Response({"detail": "Only homeowner can accept quote."}, status=status.HTTP_403_FORBIDDEN)
        if job.quote_amount is None:
            return Response({"detail": "Quote not available."}, status=status.HTTP_400_BAD_REQUEST)
        if not (job.status == "quoted" and job.quote_status == "pending"):
            return Response({"detail": "Quote can be accepted only when quote is pending."}, status=status.HTTP_400_BAD_REQUEST)

        payment_choice = (request.data.get("payment_choice") or "later").lower()
        if payment_choice not in {"now", "later"}:
            return Response({"detail": "payment_choice must be now/later."}, status=status.HTTP_400_BAD_REQUEST)

        job.quote_status = "accepted"
        job.status = "quoted"
        job.payment_status = "paid" if payment_choice == "now" else "later"
        job.save(update_fields=["quote_status", "status", "payment_status"])
        return Response(JobSerializer(job, context={"request": request}).data)

    @action(detail=True, methods=["post"])
    def reject(self, request, pk=None):
        job = get_object_or_404(Job, id=pk)
        if request.user != job.user:
            return Response({"detail": "Only homeowner can reject quote."}, status=status.HTTP_403_FORBIDDEN)
        if not (job.status == "quoted" and job.quote_status == "pending"):
            return Response({"detail": "Quote can be rejected only when quote is pending."}, status=status.HTTP_400_BAD_REQUEST)
        job.quote_status = "rejected"
        job.status = "rejected"
        job.save(update_fields=["quote_status", "status"])
        return Response(JobSerializer(job, context={"request": request}).data)

    @action(detail=True, methods=["post"], permission_classes=[IsAuthenticated, IsAdminOrSuperAdmin])
    def quote(self, request, pk=None):
        job = self.get_object()
        if job.status not in {"created", "quoted"}:
            return Response({"detail": "Quote action is allowed only for newly created jobs."}, status=status.HTTP_400_BAD_REQUEST)
        if job.status == "quoted" and job.quote_status != "pending":
            return Response({"detail": "Quote was already finalized by customer."}, status=status.HTTP_400_BAD_REQUEST)
        try:
            quote_amount = request.data.get("quote_amount")
            quote_days = int(request.data.get("quote_time_days", 0))
            quote_hours = int(request.data.get("quote_time_hours", 0))
            if quote_amount is None:
                raise ValueError
        except ValueError:
            return Response({"detail": "quote_amount and valid time are required."}, status=status.HTTP_400_BAD_REQUEST)

        job.quote_amount = quote_amount
        job.quote_time_days = max(0, quote_days)
        job.quote_time_hours = max(0, quote_hours)
        job.quote_status = "pending"
        job.status = "quoted"
        job.save(update_fields=["quote_amount", "quote_time_days", "quote_time_hours", "quote_status", "status"])
        return Response(JobSerializer(job, context={"request": request}).data)

    @action(detail=True, methods=["post"], permission_classes=[IsAuthenticated, IsAdminOrSuperAdmin])
    def assign(self, request, pk=None):
        job = self.get_object()
        if job.status != "quoted" or job.quote_status != "accepted":
            return Response(
                {"detail": "Assign is allowed only after customer acceptance."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        builder_id = request.data.get("builder_id") or request.data.get("mestri_id")
        if not builder_id:
            return Response({"detail": "builder_id is required."}, status=status.HTTP_400_BAD_REQUEST)

        mestri = get_object_or_404(User, id=builder_id)
        if mestri.role not in {"builder", "admin", "superadmin"}:
            return Response({"detail": "Assignee must be builder/admin/superadmin."}, status=status.HTTP_400_BAD_REQUEST)
        job.assigned_mestri = mestri
        if job.status in {"created", "quoted"}:
            job.status = "assigned"
        job.save(update_fields=["assigned_mestri", "status"])
        return Response(JobSerializer(job, context={"request": request}).data)

    @action(detail=True, methods=["post"])
    def start(self, request, pk=None):
        job = self.get_object()
        role = _resolved_role(request.user)
        can_start = request.user == job.assigned_mestri or role in {"admin", "superadmin"}
        if not can_start:
            return Response({"detail": "Only assigned builder can start."}, status=status.HTTP_403_FORBIDDEN)
        if job.status != "assigned":
            return Response({"detail": "Start is allowed only after assignment."}, status=status.HTTP_400_BAD_REQUEST)
        if job.quote_status == "rejected":
            return Response({"detail": "Job quote rejected."}, status=status.HTTP_400_BAD_REQUEST)
        if job.started_at is None:
            job.started_at = timezone.now()
        job.status = "started"
        job.save(update_fields=["started_at", "status"])
        return Response(JobSerializer(job, context={"request": request}).data)

    @action(detail=True, methods=["post"])
    def done(self, request, pk=None):
        job = self.get_object()
        role = _resolved_role(request.user)
        can_done = request.user == job.assigned_mestri or role in {"admin", "superadmin"}
        if not can_done:
            return Response({"detail": "Only assigned builder can mark done."}, status=status.HTTP_403_FORBIDDEN)
        if job.status != "started":
            return Response({"detail": "Done is allowed only after job is started."}, status=status.HTTP_400_BAD_REQUEST)
        has_mestri_after = job.evidences.filter(is_before=False, uploaded_by=request.user).exists()
        if not has_mestri_after:
            return Response({"detail": "Builder after evidence is mandatory."}, status=status.HTTP_400_BAD_REQUEST)
        now = timezone.now()
        if job.started_at is None:
            job.started_at = now
        job.done_at = now
        job.completed_at = now
        job.status = "done"
        if job.payment_status == "later":
            if (request.data.get("collected") or "").lower() in {"1", "true", "yes"}:
                job.payment_status = "paid"
                job.payment_reference = f"COLLECTED-{int(now.timestamp())}"
                job.save(update_fields=["started_at", "done_at", "completed_at", "status", "payment_status", "payment_reference"])
            else:
                job.save(update_fields=["started_at", "done_at", "completed_at", "status"])
        else:
            job.save(update_fields=["started_at", "done_at", "completed_at", "status"])
        return Response(JobSerializer(job, context={"request": request}).data)

    @action(detail=True, methods=["post"])
    def payment(self, request, pk=None):
        job = self.get_object()
        if request.user != job.user:
            return Response({"detail": "Only homeowner can initiate payment."}, status=status.HTTP_403_FORBIDDEN)
        if job.quote_amount is None:
            return Response({"detail": "Quote not available for payment."}, status=status.HTTP_400_BAD_REQUEST)
        mode = (request.data.get("mode") or "now").lower()
        if mode not in {"now", "later"}:
            return Response({"detail": "mode must be now/later."}, status=status.HTTP_400_BAD_REQUEST)

        now = timezone.now()
        if mode == "later":
            job.payment_status = "later"
            job.payment_reference = ""
        else:
            # Razorpay test-mode placeholder order id for MVP simulation.
            job.payment_status = "paid"
            job.payment_reference = f"pay_test_{job.id}_{int(now.timestamp())}"
        job.save(update_fields=["payment_status", "payment_reference"])
        return Response(
            {
                "payment_status": job.payment_status,
                "payment_reference": job.payment_reference,
                "message": "Payment updated in test mode.",
            }
        )

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
        if role not in {"homeowner", "builder", "admin", "superadmin"}:
            return Response({"detail": "Invalid role."}, status=status.HTTP_400_BAD_REQUEST)

        if role == "superadmin" and request.user.role != "superadmin":
            return Response({"detail": "Only superadmin can create superadmin."}, status=status.HTTP_403_FORBIDDEN)

        user.role = role
        user.save(update_fields=["role"])
        return Response(UserSerializer(user).data)

    @action(detail=True, methods=["post"], permission_classes=[IsAuthenticated, IsAdminOrSuperAdmin], url_path="review-builder")
    def review_builder(self, request, pk=None):
        user = self.get_object()
        decision = (request.data.get("decision") or "").strip().lower()
        reason = (request.data.get("reason") or "").strip()[:255]
        if decision not in {"approve", "reject"}:
            return Response({"detail": "decision must be approve/reject."}, status=status.HTTP_400_BAD_REQUEST)

        now = timezone.now()
        if decision == "approve":
            user.mestri_request_status = "approved"
            user.mestri_reviewed_at = now
            user.mestri_reject_reason = ""
            user.mestri_reapply_after = None
            if user.role not in {"admin", "superadmin"}:
                user.role = "builder"
            user.save(
                update_fields=[
                    "mestri_request_status",
                    "mestri_reviewed_at",
                    "mestri_reject_reason",
                    "mestri_reapply_after",
                    "role",
                ]
            )
        else:
            user.mestri_request_status = "rejected"
            user.mestri_reviewed_at = now
            user.mestri_reject_reason = reason
            user.mestri_reapply_after = now + timedelta(days=7)
            user.save(
                update_fields=[
                    "mestri_request_status",
                    "mestri_reviewed_at",
                    "mestri_reject_reason",
                    "mestri_reapply_after",
                ]
            )
        return Response(UserSerializer(user).data)


class VijayView(APIView):
    """Simple diagnostic endpoint available at /api/vijay

    GET: returns a greeting and basic authenticated user info (if present).
    """
    permission_classes = []

    def get(self, request):
        user = getattr(request, "user", None)
        payload = {"message": "Hello Vijay"}
        if user is not None and getattr(user, "is_authenticated", False):
            payload["user"] = {
                "id": getattr(user, "id", None),
                "username": getattr(user, "username", ""),
                "role": getattr(user, "role", None),
            }
        return Response(payload)


class VijayAgentView(APIView):
    """Django-compatible Vijay agent endpoint for mobile app fallback."""

    permission_classes = [IsAuthenticated]

    PRIORITY_PHONE = "9000570010"
    PRIORITY_AREAS = {"sangareddy", "patancheru", "indersham", "kukatpally"}

    def post(self, request):
        message = (request.data.get("message") or "").strip()
        location = (request.data.get("location") or "").strip()
        max_results = int(request.data.get("max_results") or 5)

        if not message or not location:
            return Response(
                {"detail": "message and location are required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        normalized = location.lower()
        is_priority = any(area in normalized for area in self.PRIORITY_AREAS)

        if is_priority:
            contractors = [
                {
                    "name": "Vijay",
                    "phone": self.PRIORITY_PHONE,
                    "location": location,
                    "rating": None,
                    "specialty": "General Construction",
                    "last_updated": timezone.now().isoformat(),
                }
            ]
            mode = "priority_contact"
            reply = (
                f"For {location}, contact Vijay at {self.PRIORITY_PHONE}. "
                "He is the priority contractor for this zone."
            )
        else:
            contractors = []
            try:
                from tools.contractor_scraper_api import scrape_contractors

                rows = scrape_contractors(
                    areas=[location],
                    max_results_per_area=max(1, min(max_results, 20)),
                    source="auto",
                )
                contractors = [r.model_dump() for r in rows]
            except Exception:
                contractors = []

            mode = "scraped_recommendations"
            reply = f"I found top contractor options for {location}. Please review and proceed."

        payload = {
            "persona": "vijay",
            "mode": mode,
            "message": reply,
            "actions": [
                {"type": "suggest_contractors", "enabled": True},
                {"type": "start_quote_flow", "enabled": True},
            ],
            "contractors": contractors,
            "timestamp": timezone.now().isoformat(),
        }
        return Response(payload)


class BuilderRequestView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)

    def post(self, request):
        user = request.user
        role = _resolved_role(user)
        if role in {"builder", "admin", "superadmin"}:
            user.mestri_request_status = "approved"
            user.save(update_fields=["mestri_request_status"])
            return Response(UserSerializer(user).data)

        now = timezone.now()
        if user.mestri_request_status == "pending":
            return Response({"detail": "Request already pending."}, status=status.HTTP_400_BAD_REQUEST)
        if user.mestri_request_status == "rejected" and user.mestri_reapply_after and user.mestri_reapply_after > now:
            return Response(
                {
                    "detail": "Apply again after waiting period.",
                    "reapply_after": user.mestri_reapply_after,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        user.mestri_request_status = "pending"
        user.mestri_requested_at = now
        user.mestri_reviewed_at = None
        user.mestri_reject_reason = ""
        user.save(
            update_fields=[
                "mestri_request_status",
                "mestri_requested_at",
                "mestri_reviewed_at",
                "mestri_reject_reason",
            ]
        )
        return Response(UserSerializer(user).data, status=status.HTTP_202_ACCEPTED)


class MestriRequestView(BuilderRequestView):
    """Backward-compatible alias for legacy clients."""


class EvidenceUploadView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        job_id = request.data.get("job_id")
        if not job_id:
            return Response({"detail": "job_id is required."}, status=status.HTTP_400_BAD_REQUEST)

        job = get_object_or_404(Job, id=job_id)
        serializer = EvidenceSerializer(data=request.data, context={"request": request, "job": job})
        serializer.is_valid(raise_exception=True)
        evidence = serializer.save()
        return Response(EvidenceSerializer(evidence).data, status=status.HTTP_201_CREATED)


class RatingCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        job_id = request.data.get("job_id")
        if not job_id:
            return Response({"detail": "job_id is required."}, status=status.HTTP_400_BAD_REQUEST)

        job = get_object_or_404(Job, id=job_id)
        payload = None

        rating_raw = request.data.get("rating")
        if rating_raw is not None:
            value = str(rating_raw).strip().lower()
            if value in {"true", "1", "yes", "like", "thumbsup", "up"}:
                normalized = "like"
            elif value in {"false", "0", "no", "dislike", "thumbsdown", "down"}:
                normalized = "dislike"
            else:
                return Response(
                    {"detail": "rating must be true/false (or like/dislike)."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            payload = {
                "rating": normalized,
                "comments": (request.data.get("comment") or request.data.get("comments") or "").strip(),
            }
        else:
            overall = (request.data.get("overall") or "").lower()
            quality = (request.data.get("quality") or "").lower()
            speed = (request.data.get("speed") or "").lower()

            allowed = {"like", "dislike"}
            if overall not in allowed or quality not in allowed or speed not in allowed:
                return Response(
                    {"detail": "overall, quality and speed must be like/dislike."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            payload = {
                "rating": overall,
                "comments": f"overall={overall};quality={quality};speed={speed}",
            }

        serializer = RatingSerializer(data=payload, context={"request": request, "job": job})
        serializer.is_valid(raise_exception=True)
        rating = serializer.save()
        return Response(RatingSerializer(rating).data, status=status.HTTP_201_CREATED)


class InterestCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = InterestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        interest = Interest.objects.create(
            user=request.user,
            area=serializer.validated_data["area"],
            message=serializer.validated_data.get("message", ""),
        )
        return Response(InterestSerializer(interest).data, status=status.HTTP_201_CREATED)
