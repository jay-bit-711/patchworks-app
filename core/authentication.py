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
        if not uid:
            raise exceptions.AuthenticationFailed("Token missing uid.")

        username = (email.split("@")[0] if email else f"user_{uid[:12]}")[:150]
        user, _ = User.objects.get_or_create(
            firebase_uid=uid,
            defaults={
                "username": username,
                "email": email,
                "first_name": decoded.get("name", "")[:150],
            },
        )

        changed = False
        if email and user.email != email:
            user.email = email
            changed = True
        if not user.username:
            user.username = username
            changed = True
        if changed:
            user.save(update_fields=["email", "username"])

        return user, token
