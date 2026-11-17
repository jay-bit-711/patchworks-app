# Stage 2 — Enquiry Intake and CRM Foundation

## Scope delivered on this branch

- Added a `Lead` record to the existing Django `core` app.
- Added an unauthenticated website intake endpoint: `POST /api/leads/`.
- Added Indian mobile-number normalization and validation.
- Added a quiet honeypot response for basic bot submissions.
- Kept CRM-only fields (`status`, `assigned_to`, timestamps) server-controlled.
- Added Django Admin list, search, filters and inline status/owner assignment.
- Added API tests for valid public submission, invalid phone rejection and honeypot handling.

## Lead lifecycle

`new → contacted → qualified → quoted → converted`

A lead may instead be marked `lost`. Status and assignment are managed by staff in Django Admin.

## Request contract

```json
{
  "name": "Customer or business name",
  "phone": "9876543210",
  "email": "optional@example.com",
  "lead_type": "homeowner",
  "service": "Plumbing",
  "location": "Kondapur, Hyderabad",
  "details": "Brief requirement",
  "source_url": "https://patchworks.in/services/plumbing.html"
}
```

Allowed `lead_type` values: `homeowner`, `contractor`, `developer`.

Success: HTTP 201 with a lead ID. Invalid Indian mobile numbers return HTTP 400. The endpoint does not accept a caller-supplied CRM status or assignee.

## Deployment and verification still required

1. Confirm the production Django API host and database before connecting the public website.
2. Add the Django backend's actual runtime dependencies to the deployment requirements. The current root `requirements.txt` contains only Firebase/OpenAI packages even though the `Procfile` starts Gunicorn and the application imports Django and Django REST Framework.
3. Configure HTTPS and cross-origin access for `https://patchworks.in` and `https://www.patchworks.in` before browser-based form submission.
4. Apply migrations with `python manage.py migrate`.
5. Run `python manage.py test core` and verify the endpoint in staging.
6. Configure the website to post to the confirmed API host. Until then, existing WhatsApp enquiry behaviour remains unchanged.

## Deliberate non-changes

- No production website deployment or DNS change.
- No Firebase project switch or Firestore rule change.
- No payment, quote, contractor assignment or project workflow changes.
- No public lead-list endpoint; staff review leads through Django Admin.
