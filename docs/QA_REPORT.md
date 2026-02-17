# QA Report (MVP)

## Automated
- Backend tests executed: `./venv/bin/python manage.py test core.tests.PatchworksApiTests`
- Result: PASS (6/6)

## Covered journeys
- Homeowner can create jobs until cap (8)
- Evidence upload allowed for authorized user, capped at 2 files/job
- Evidence upload blocked when file > 50MB
- Mestri can accept unassigned jobs
- Admin role upgrade endpoint guard enforced
- Rating blocked until job is `done`, then allowed
- Two-way rating validated: homeowner -> mestri and mestri -> homeowner
- Dedicated `/api/evidence/upload/` endpoint validated

## Manual test checklist (Flutter)
1. Google sign in and role sync via `/api/auth/sync/`.
2. Homeowner creates job and uploads evidence.
3. Mestri accepts and marks job done.
4. Homeowner rates with 👍/👎.
5. Admin upgrades role to mestri/admin.
6. Telugu toggle and haptics/confetti UX feedback.
