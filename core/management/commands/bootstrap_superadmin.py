from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = "Create or update the Patchworks bootstrap super admin."

    def handle(self, *args, **options):
        User = get_user_model()
        email = "jayanthedara@gmail.com"
        phone = "+919441828722"

        user, created = User.objects.get_or_create(
            email=email,
            defaults={
                "username": "patchworks_superadmin",
                "phone": phone,
                "role": "superadmin",
                "is_staff": True,
                "is_superuser": True,
            },
        )

        if not created:
            user.phone = phone
            user.role = "superadmin"
            user.is_staff = True
            user.is_superuser = True
            if not user.username:
                user.username = "patchworks_superadmin"
            user.save(update_fields=["phone", "role", "is_staff", "is_superuser", "username"])

        self.stdout.write(self.style.SUCCESS(f"Super admin ready: {user.email}"))
