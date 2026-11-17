from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    dependencies = [
        ("core", "0010_builder_role_rename"),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name="Lead",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("name", models.CharField(max_length=120)),
                ("phone", models.CharField(db_index=True, max_length=16)),
                ("email", models.EmailField(blank=True, max_length=254)),
                ("lead_type", models.CharField(choices=[("homeowner", "Homeowner enquiry"), ("contractor", "Contractor partnership"), ("developer", "Developer enquiry")], default="homeowner", max_length=20)),
                ("service", models.CharField(blank=True, max_length=80)),
                ("location", models.CharField(blank=True, max_length=180)),
                ("details", models.TextField(blank=True)),
                ("source_url", models.URLField(blank=True, max_length=500)),
                ("status", models.CharField(choices=[("new", "New"), ("contacted", "Contacted"), ("qualified", "Qualified"), ("quoted", "Quoted"), ("converted", "Converted"), ("lost", "Lost")], db_index=True, default="new", max_length=16)),
                ("created_at", models.DateTimeField(auto_now_add=True, db_index=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("assigned_to", models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name="assigned_leads", to=settings.AUTH_USER_MODEL)),
            ],
            options={"ordering": ["-created_at"]},
        ),
    ]
