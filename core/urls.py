from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import AdminUserViewSet, AuthSyncView, EvidenceUploadView, JobViewSet

router = DefaultRouter()
router.register(r"jobs", JobViewSet, basename="job")
router.register(r"admin/users", AdminUserViewSet, basename="admin-users")

urlpatterns = [
    path("auth/sync/", AuthSyncView.as_view(), name="auth-sync"),
    path("evidence/upload/", EvidenceUploadView.as_view(), name="evidence-upload"),
    path("", include(router.urls)),
]
