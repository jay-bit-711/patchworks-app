import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "patchworks_backend.settings")

from django.core.wsgi import get_wsgi_application

app = get_wsgi_application()
