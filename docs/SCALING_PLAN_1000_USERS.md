# Patchworks Scaling Plan (1000 Users)

## Traffic assumptions
- 1000 registered users
- 100-200 DAU
- 10-20 concurrent active users
- 500-1200 API requests/day
- Evidence uploads: 2 files/job, <=50MB each

## Infra target
- Heroku web dynos: 2x Eco/Basic to start; auto-scale to 3-4 Standard-1X during growth
- Gunicorn workers: 2-3 per dyno, threads 2
- Postgres: Heroku Postgres Mini -> Standard-0 when nearing 10k jobs/evidence metadata growth
- Firebase Storage: primary binary storage
- Cache: Redis (Heroku Redis Mini) for hot list endpoints and rate-limiting counters

## Security
- Firebase ID token verification per request
- Role-based backend authorization (homeowner/mestri/admin/superadmin)
- HTTPS-only in production, secure cookies
- CORS restricted to app domains
- Secrets only via Heroku config vars
- Super admin bootstrap account:
  - email: `jayanthedara@gmail.com`
  - phone: `+919441828722`

## Observability
- Sentry for Django + Flutter crash/error tracking
- Heroku log drains to Papertrail/Datadog
- Health endpoint + uptime monitor every 1 min
- Alerts:
  - API 5xx > 2% for 5 min
  - p95 latency > 900ms for 10 min
  - storage errors > 1% uploads

## Performance actions
- DB indexes on `Job(user,status,created_at)`, `Evidence(job,timestamp)`, `User(role)`
- Pagination for `/api/jobs/` and `/api/admin/users/`
- Cache job list (short TTL 30-60s)
- Async upload post-processing with Celery/RQ in next phase

## Cost estimate (monthly, approx)
- Heroku dynos (2 Basic): $14-$50
- Heroku Postgres (Mini/Standard-0): $5-$50
- Heroku Redis Mini: $3-$15
- Firebase storage + egress: $10-$60 (depends on upload volume)
- Monitoring (Sentry/Papertrail starter): $0-$30
- Total: ~$32 to $205/month

## Rollout path
1. Week 1: single dyno + Postgres Mini + Firebase storage + manual monitoring.
2. Week 2: add second dyno, Redis cache, Sentry alerts.
3. Week 3+: add async workers and rate limits if DAU > 300.
