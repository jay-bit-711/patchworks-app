from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, Job, Evidence

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
admin.site.register(Evidence)