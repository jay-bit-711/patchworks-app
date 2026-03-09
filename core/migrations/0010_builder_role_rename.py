from django.db import migrations, models


def migrate_mestri_to_builder(apps, schema_editor):
    User = apps.get_model("core", "User")
    User.objects.filter(role="mestri").update(role="builder")


def reverse_builder_to_mestri(apps, schema_editor):
    User = apps.get_model("core", "User")
    User.objects.filter(role="builder").update(role="mestri")


class Migration(migrations.Migration):

    dependencies = [
        ("core", "0009_user_mestri_reapply_after_user_mestri_reject_reason_and_more"),
    ]

    operations = [
        migrations.RunPython(migrate_mestri_to_builder, reverse_builder_to_mestri),
        migrations.AlterField(
            model_name="user",
            name="role",
            field=models.CharField(
                choices=[
                    ("homeowner", "Home Owner"),
                    ("admin", "Admin"),
                    ("builder", "Builder"),
                    ("superadmin", "Super Admin"),
                ],
                default="homeowner",
                max_length=20,
            ),
        ),
        migrations.AlterField(
            model_name="job",
            name="assigned_mestri",
            field=models.ForeignKey(
                blank=True,
                limit_choices_to={"role": "builder"},
                null=True,
                on_delete=models.deletion.SET_NULL,
                related_name="assigned_jobs",
                to="core.user",
            ),
        ),
    ]
