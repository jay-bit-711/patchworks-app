from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from .models import Evidence, Job

User = get_user_model()


class PatchworksApiTests(APITestCase):
    def setUp(self):
        self.homeowner = User.objects.create_user(username="home1", password="pass", role="homeowner")
        self.mestri = User.objects.create_user(username="mestri1", password="pass", role="mestri")
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

    def test_mestri_accept_job(self):
        job = Job.objects.create(user=self.homeowner, description="Tap fix", location="Madhapur")
        self.client.force_authenticate(self.mestri)
        response = self.client.post(f"/api/jobs/{job.id}/accept/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        job.refresh_from_db()
        self.assertEqual(job.assigned_mestri_id, self.mestri.id)
        self.assertEqual(job.status, "in_progress")

    def test_only_admin_can_upgrade_role(self):
        self.client.force_authenticate(self.homeowner)
        response = self.client.post(f"/api/admin/users/{self.mestri.id}/upgrade/", {"role": "admin"}, format="json")
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

        self.client.force_authenticate(self.admin)
        response = self.client.post(
            f"/api/admin/users/{self.homeowner.id}/upgrade/", {"role": "mestri"}, format="json"
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_rating_only_after_done(self):
        job = Job.objects.create(
            user=self.homeowner,
            assigned_mestri=self.mestri,
            status="in_progress",
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

    def tearDown(self):
        Evidence.objects.all().delete()
