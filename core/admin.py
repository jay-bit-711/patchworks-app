# core/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, Job, Evidence, Rating  # ← Add Rating here!
# core/admin.py (add this class and update registration)

from .forms import EvidenceAdminForm
from django.utils.html import mark_safe


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
    list_display = ('job', 'is_before', 'timestamp', 'file_link', 'file_size_display', 'file_url')
    list_filter = ('is_before', 'job__status')
    readonly_fields = ('file_size', 'timestamp', 'file_url')

    def save_model(self, request, obj, form, change):
        if 'file' in form.changed_data and form.cleaned_data.get('file'):
            obj._temp_content_type = form.cleaned_data['file'].content_type
        super().save_model(request, obj, form, change)
    def file_link(self, obj):
        if obj.file:
            return mark_safe(f'<a href="{obj.file.url}" target="_blank">{obj.file.name}</a>')
        return "-"
    file_link.short_description = "File"

    def file_size_display(self, obj):
        if obj.file_size:
            return f"{obj.file_size / 1024:.2f} KB" if obj.file_size < 1024*1024 else f"{obj.file_size / (1024*1024):.2f} MB"
        return "0"
    file_size_display.short_description = "Size"