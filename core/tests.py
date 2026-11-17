from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework import status
from rest_framework.test import APITestCase

from .models import Evidence, Job

User = get_user_model()


class PatchworksApiTests(APITestCase):
    def setUp(self):
        self.homeowner = User.objects.create_user(username="home1", password="pass", role="homeowner")
        self.builder = User.objects.create_user(username="builder1", password="pass", role="builder")
        self.admin = User.objects.create_user(username="admin1", password="pass", role="admin")
        self.superadmin = User.objects.create_user(username="sa1", password="pass", role="superadmin")

    def test_homeowner_job_cap_is_8(self):
        self.client.force_authenticate(self.homeowner)
        for idx in range(8):
            response = self.client.post(
                "/api/jobs/",
                {"description": f"Leak {idx}", "location": "Hyderabad"},
                format="json",
            )
            self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        response = self.client.post(
            "/api/jobs/",
            {"description": "Overflow", "location": "Hyderabad"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_evidence_limit_and_size_guard(self):
        job = Job.objects.create(user=self.homeowner, description="Pipe issue", location="Ameerpet")
        self.client.force_authenticate(self.homeowner)

        for _ in range(2):
            file_obj = SimpleUploadedFile("proof.jpg", b"x" * 1024, content_type="image/jpeg")
            response = self.client.post(
                f"/api/jobs/{job.id}/evidences/",
                {"file": file_obj, "is_before": True},
                format="multipart",
            )
            self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        third_file = SimpleUploadedFile("third.jpg", b"x" * 1024, content_type="image/jpeg")
        response = self.client.post(
            f"/api/jobs/{job.id}/evidences/",
            {"file": third_file, "is_before": False},
            format="multipart",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

        big_payload = b"x" * (50 * 1024 * 1024 + 1)
        big_file = SimpleUploadedFile("big.mp4", big_payload, content_type="video/mp4")
        other_job = Job.objects.create(user=self.homeowner, description="Wall crack", location="KPHB")
        response = self.client.post(
            f"/api/jobs/{other_job.id}/evidences/",
            {"file": big_file, "is_before": True},
            format="multipart",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_builder_accept_job(self):
        job = Job.objects.create(user=self.homeowner, description="Tap fix", location="Madhapur")
        self.client.force_authenticate(self.builder)
        response = self.client.post(f"/api/jobs/{job.id}/accept/")
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        job.refresh_from_db()
        self.assertIsNone(job.assigned_mestri_id)
        self.assertEqual(job.status, "created")

    def test_only_admin_can_upgrade_role(self):
        self.client.force_authenticate(self.homeowner)
        response = self.client.post(f"/api/admin/users/{self.builder.id}/upgrade/", {"role": "admin"}, format="json")
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

        self.client.force_authenticate(self.admin)
        response = self.client.post(
            f"/api/admin/users/{self.homeowner.id}/upgrade/", {"role": "builder"}, format="json"
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_rating_only_after_done(self):
        job = Job.objects.create(
            user=self.homeowner,
            assigned_mestri=self.builder,
            status="assigned",
            description="AC leak",
            location="Gachibowli",
        )

        self.client.force_authenticate(self.homeowner)
        response = self.client.post(
            f"/api/jobs/{job.id}/rate/",
            {"rating": "like", "comments": "Good"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

        job.status = "done"
        job.save(update_fields=["status"])
        response = self.client.post(
            f"/api/jobs/{job.id}/rate/",
            {"rating": "like", "comments": "Good"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["rating"], "like")

        self.client.force_authenticate(self.builder)
        response = self.client.post(
            f"/api/jobs/{job.id}/rate/",
            {"rating": "dislike", "comments": "Owner unavailable"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["rating"], "dislike")

    def test_evidence_upload_endpoint(self):
        job = Job.objects.create(user=self.homeowner, assigned_mestri=self.builder, description="Door repair", location="Kondapur")

        self.client.force_authenticate(self.builder)
        file_obj = SimpleUploadedFile("door.jpg", b"x" * 1024, content_type="image/jpeg")
        response = self.client.post(
            "/api/evidence/upload/",
            {"job_id": job.id, "file": file_obj, "is_before": False},
            format="multipart",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["job"], job.id)

    def tearDown(self):
        Evidence.objects.all().delete()


class PublicLeadIntakeTests(APITestCase):
    def test_website_can_submit_valid_lead_without_login(self):
        response = self.client.post(
            "/api/leads/",
            {
                "name": "Asha Rao",
                "phone": "9876543210",
                "lead_type": "homeowner",
                "service": "Plumbing",
                "location": "Kondapur, Hyderabad",
                "details": "Bathroom renovation enquiry",
                "source_url": "https://patchworks.in/services/plumbing.html",
            },
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        from .models import Lead
        lead = Lead.objects.get(pk=response.data["id"])
        self.assertEqual(lead.phone, "+919876543210")
        self.assertEqual(lead.status, "new")

    def test_invalid_phone_is_rejected(self):
        response = self.client.post(
            "/api/leads/",
            {"name": "Asha", "phone": "12345"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_honeypot_submission_is_discarded(self):
        response = self.client.post(
            "/api/leads/",
            {"name": "Bot", "phone": "9876543210", "website": "https://spam.example"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        from .models import Lead
        self.assertEqual(Lead.objects.count(), 0)
