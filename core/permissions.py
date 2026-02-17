from rest_framework.permissions import BasePermission


class IsAdminOrSuperAdmin(BasePermission):
    def has_permission(self, request, view):
        user = request.user
        return bool(user and user.is_authenticated and user.role in {"admin", "superadmin"})
