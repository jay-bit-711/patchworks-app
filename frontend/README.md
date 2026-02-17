# Patchworks Flutter App (Android MVP)

## Features
- Google SSO via Firebase
- Role-aware dashboard (homeowner, mestri, admin, superadmin)
- Homeowner: post job, upload evidence, rate done jobs (👍/👎)
- Mestri: view assigned jobs, accept unassigned jobs, mark done
- Admin/Super Admin: list users and upgrade roles
- Telugu toggle, haptics, confetti success feedback

## Prerequisites
- Flutter SDK 3.24+
- Android SDK + emulator/device
- Firebase Android config (`google-services.json`) from project `patchworks-3178f`

## Setup
```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

## Build APK
```bash
cd frontend
flutter build apk --release --dart-define=API_BASE_URL=https://<your-backend-domain>/api
```

## Notes
- `lib/main.dart` currently contains full MVP UI + API client in a single file for speed.
- For production, split into modules (`features/`, `services/`, `models/`) and add secure env handling.
