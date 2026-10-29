# Patchworks v2 Clean Build

**Motto:** Trust but Verify 🕵️

Built with love from Patancheru 🧡🖤 (SRH Orange #FF7A00 & Deep Black #121212)

## Stack (clean — old Firebase / Supabase / Heroku keys expired)
- Flutter (Android first)
- Python FastAPI (preferred) or Django
- Postgres (new Supabase / Railway / local SQLite for dev)
- Pure UPI deep-link + unique ref + proof/status (no Razorpay)

## Monetization
₹150 from Customer + ₹150 from Skilled Pro = ₹300 pool per site visit.
Collected via UPI to Super Admin account.
**Gate:** Both payments verified before unlocking direct call + GPS site navigation.

## Roles
- Homeowner / Customer
- Skilled Professional / Mestri / Builder (skills: plumber, electrician, mason, painter, contractor, etc.)
- Super Admin (Jayanth) — full control + revenue

## Focus
Hyderabad first (Patancheru / Sangareddy / RC Puram corridor).
EN / Te toggle. Minimal text + emojis. Evidence = photos/videos + timestamps.
Direct price negotiation (no platform commission).

## Current
- Branch: `v2-clean-build`
- Clean domain models in `backend/models.py` (SiteVisit with dual fee unlock logic)
- Next: FastAPI endpoints for UPI initiate + confirm + unlock check

## Next Steps
1. FastAPI backend skeleton + SiteVisit fee endpoints
2. Flutter UPI deep-link screen + payment status poll
3. Website update for ₹150 fee messaging
