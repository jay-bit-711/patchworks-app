from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import (
    AdminUserViewSet,
    AuthSyncView,
    MestriRequestView,
    EvidenceUploadView,
    InterestCreateView,
    JobViewSet,
    BuilderRequestView,
    RatingCreateView,
    VijayView,
    VijayAgentView,
)

router = DefaultRouter()
router.register(r"jobs", JobViewSet, basename="job")
router.register(r"admin/users", AdminUserViewSet, basename="admin-users")

urlpatterns = [
    path("auth/sync/", AuthSyncView.as_view(), name="auth-sync"),
    path("builder/request/", BuilderRequestView.as_view(), name="builder-request"),
    path("mestri/request/", MestriRequestView.as_view(), name="mestri-request"),
    path("evidence/upload/", EvidenceUploadView.as_view(), name="evidence-upload"),
    path("ratings/", RatingCreateView.as_view(), name="ratings-create"),
    path("interest/", InterestCreateView.as_view(), name="interest-create"),
    path("vijay/", VijayView.as_view(), name="vijay"),
    path("vijay/agent/", VijayAgentView.as_view(), name="vijay-agent"),
    path("", include(router.urls)),
]
