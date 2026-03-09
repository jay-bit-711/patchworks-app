# core/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.utils.html import format_html
from .models import User, Job, Evidence, Rating  # ← Add Rating here!
# core/admin.py (add this class and update registration)

from .forms import EvidenceAdminForm


class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'role', 'phone', 'is_staff', 'is_superuser')
    list_filter = ('role', 'is_staff', 'is_superuser')
    fieldsets = UserAdmin.fieldsets + (
        ('Patchworks Extra', {'fields': ('role', 'phone', 'firebase_uid')}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Patchworks Extra', {'fields': ('role', 'phone')}),
    )


admin.site.register(User, CustomUserAdmin)
admin.site.register(Job)
admin.site.register(Rating)  # Now it knows what Rating is
@admin.register(Evidence)
class EvidenceAdmin(admin.ModelAdmin):
    form = EvidenceAdminForm
    list_display = ('job', 'is_before', 'timestamp', 'file_link', 'preview_link', 'file_size_display')
    list_filter = ('is_before', 'job__status')
    readonly_fields = ('file_size', 'timestamp', 'file_url_display')

    def save_model(self, request, obj, form, change):
        if 'file' in form.changed_data and form.cleaned_data.get('file'):
            obj._temp_content_type = form.cleaned_data['file'].content_type
        super().save_model(request, obj, form, change)

    def file_link(self, obj):
        if obj.file:
            return format_html(
                '<a href="{}" target="_blank" rel="noopener noreferrer">{}</a>',
                obj.file.url,
                obj.file.name,
            )
        return "-"
    file_link.short_description = "File"

    @admin.display(description="File URL (opens in new tab)")
    def file_url_display(self, obj):
        if not obj.file_url:
            return "No file"
        label = (obj.file.name.rsplit("/", 1)[-1] if obj.file else obj.file_url.rsplit("/", 1)[-1]) or "View file"
        return format_html(
            '<a href="{}" target="_blank" rel="noopener noreferrer">{}</a>',
            obj.file_url,
            label,
        )

    @admin.display(description="View file")
    def preview_link(self, obj):
        if not obj.file_url:
            return "-"
        return format_html(
            '<a href="{}" target="_blank" rel="noopener noreferrer">View file</a>',
            obj.file_url,
        )

    def file_size_display(self, obj):
        if obj.file_size:
            return f"{obj.file_size / 1024:.2f} KB" if obj.file_size < 1024*1024 else f"{obj.file_size / (1024*1024):.2f} MB"
        return "0"
    file_size_display.short_description = "Size"
