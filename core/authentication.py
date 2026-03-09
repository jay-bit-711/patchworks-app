from django.contrib.auth import get_user_model
from rest_framework import authentication, exceptions

from .firebase import verify_id_token

User = get_user_model()

class FirebaseAuthentication(authentication.BaseAuthentication):
    keyword = "Bearer"

    def authenticate(self, request):
        header = request.headers.get("Authorization", "")
        if not header:
            return None

        parts = header.split(" ", 1)
        if len(parts) != 2 or parts[0] != self.keyword:
            raise exceptions.AuthenticationFailed("Invalid authorization header format.")

        token = parts[1].strip()
        if not token:
            raise exceptions.AuthenticationFailed("Missing token.")

        try:
            decoded = verify_id_token(token)
        except ValueError as exc:
            raise exceptions.AuthenticationFailed(str(exc)) from exc

        uid = decoded.get("uid")
        email = decoded.get("email") or ""
        phone_number = decoded.get("phone_number") or ""
        if not uid:
            raise exceptions.AuthenticationFailed("Token missing uid.")

        username = (email.split("@")[0] if email else f"user_{uid[:12]}")[:150]
        user = User.objects.filter(firebase_uid=uid).first()
        if user is None and email:
            # Link existing Django account (admin/superadmin created in admin panel)
            # to Firebase UID instead of creating a duplicate homeowner account.
            user = User.objects.filter(email__iexact=email).first()
            if user is not None:
                user.firebase_uid = uid
                user.save(update_fields=["firebase_uid"])

        if user is None:
            user = User.objects.create(
                firebase_uid=uid,
                username=username,
                email=email,
                first_name=decoded.get("name", "")[:150],
            )

        changed = False
        if email and user.email != email:
            user.email = email
            changed = True
        if not user.username:
            user.username = username
            changed = True
        if phone_number and user.phone != phone_number:
            user.phone = phone_number
            changed = True
        if user.is_superuser and user.role != "superadmin":
            user.role = "superadmin"
            changed = True
        elif user.is_staff and user.role not in {"admin", "superadmin"}:
            user.role = "admin"
            changed = True
        if changed:
            user.save(update_fields=["email", "username", "phone", "role"])

        return user, token
