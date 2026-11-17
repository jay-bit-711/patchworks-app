# Patchworks API deployment

## Target architecture

- Django REST Framework API deployed as a Vercel Python Function.
- Managed PostgreSQL via a Vercel Marketplace provider (Neon is the initial recommendation).
- Firebase Admin SDK remains responsible for Firebase ID-token verification and Firebase Storage access.
- Website and API deploy independently; the production website remains unchanged until staging tests pass.

## Required Vercel environment variables

| Variable | Purpose |
| --- | --- |
| `DJANGO_SECRET_KEY` | Unique high-entropy Django signing secret |
| `DJANGO_DEBUG` | Set to `0` |
| `DJANGO_ALLOWED_HOSTS` | API hostname, `.vercel.app`, localhost for previews if required |
| `DATABASE_URL` | Managed PostgreSQL connection string |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Firebase service-account JSON, stored as a sensitive environment variable |
| `FIREBASE_STORAGE_BUCKET` | Existing Patchworks Firebase Storage bucket |
| `CORS_ALLOWED_ORIGINS` | Website origin(s), including preview when testing |
| `CSRF_TRUSTED_ORIGINS` | Trusted HTTPS website/API origins |

Never commit service-account JSON, database URLs, Django secrets, or API keys.

## First deployment sequence

1. Create a separate Vercel project named `patchworks-api`, linked to this repository, root directory at repository root.
2. Provision a managed PostgreSQL database in the same nearby region as the API functions.
3. Add all environment variables to Preview first.
4. Deploy branch `premium-rebrand-round-1`.
5. Run `python manage.py migrate` against the preview database and create the first staff superuser through a secure one-time admin process.
6. Verify `/admin/`, Firebase token authentication, `POST /api/leads/`, CORS and rate limiting.
7. Only after verification, configure Production variables and connect the public website forms.

## Important operating notes

- Vercel Functions are stateless. SQLite and local media storage are not production data stores.
- PostgreSQL is required before running the production API.
- User uploads must continue to use Firebase Storage; do not rely on the function filesystem.
- Run migrations as a controlled release step, not on every request.
- Keep preview and production databases separate.
