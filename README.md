# Patchworks MVP

Patchworks is a Hyderabad-focused home repair app MVP with role-based access for Home Owner, Mestri/Plumber, Admin, and Super Admin.

## Stack
- Backend: Django + DRF + Firebase auth/storage hooks
- Frontend: Flutter (Android-first, iOS-ready)
- Auth: Google SSO via Firebase
- Storage: Firebase Storage (opt-in from backend)
- Payments: Razorpay test mode placeholder (future UPI phase)

## Backend setup
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

## Backend env
- `DJANGO_SECRET_KEY`
- `DJANGO_DEBUG` (`1` local, `0` prod)
- `DJANGO_ALLOWED_HOSTS` (comma-separated)
- `DATABASE_URL` (Heroku Postgres)
- `FIREBASE_CREDENTIALS_PATH` (path to service account json)
- `FIREBASE_STORAGE_BUCKET` (`patchworks-3178f.firebasestorage.app`)
- `ENABLE_FIREBASE_STORAGE` (`1` to upload files to Firebase, `0` for local/test)

## API routes
- `GET /api/auth/sync/`
- `GET,POST /api/jobs/`
- `PATCH /api/jobs/{id}/`
- `POST /api/jobs/{id}/accept/`
- `POST /api/jobs/{id}/assign/` (admin/superadmin)
- `GET,POST /api/jobs/{id}/evidences/`
- `POST /api/jobs/{id}/rate/`
- `GET /api/admin/users/`
- `POST /api/admin/users/{id}/upgrade/`

## Guards implemented
- Max 8 jobs per home owner
- Max 2 evidences per job
- Max 50MB per evidence
- Role-based access for job actions and user upgrades
- Ratings only when job status is `done`

## Flutter app
See `/frontend/README.md`.

## Heroku deploy
```bash
heroku create patchworks-app
heroku addons:create heroku-postgresql:mini
heroku config:set DJANGO_DEBUG=0
heroku config:set DJANGO_SECRET_KEY=<secure>
heroku config:set DJANGO_ALLOWED_HOSTS=patchworks.in,www.patchworks.in,<app>.herokuapp.com
heroku config:set ENABLE_FIREBASE_STORAGE=1
heroku config:set FIREBASE_STORAGE_BUCKET=patchworks-3178f.firebasestorage.app
git push heroku main
heroku run python manage.py migrate
```

## Tests
```bash
./venv/bin/python manage.py test core.tests.PatchworksApiTests
```
