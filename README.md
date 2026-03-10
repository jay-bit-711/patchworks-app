# Patchworks

## 🎯 Vision & Mission

**Motto:** *Trust but Verify.*

**Vision:** Providing a digital trail of their end-to-end home needs.

**Mission:** Our mission is to empower construction teams with an intelligent, mobile-first ecosystem that simplifies project complexity. By integrating real-time site data, automated documentation via specialized AI agents, and secure financial tools, we ensure every project is delivered with precision and accountability.

---

## ✅ Current Project Status (Build: Mar 10)
- **Security**: Granular Firestore & Storage rules enforced. 100MB Video/Image evidence support implemented.
- **Auth**: End-to-end Google SSO with Role-Based routing (Homeowner vs. Builder).
- **UI/UX**: Cinematic, auto-playing onboarding flow and high-density Job Management Dashboard.
- **AI Agents**: Integrated **Agent Vijay 👷** (Construction Expert) and **Agent Material 📦** (Logistics).
- **Architecture**: Implemented "Verified Head" task-based tracking for trade lead accountability.
- **Performance**: Repository surgically cleaned and optimized (<50MB source code).

---

## 🛠 Surgical Cleanup
The repository has been surgically cleaned to maintain a lean footprint. Misplaced Android SDK tools (`build-tools`, `platforms`, etc.) and redundant project copies have been removed to ensure a professional developer environment.

## 🏗 "Verified Head" Architecture
We have digitized individual accountability for every trade lead:
- **Task-Based Tracking**: A Project is broken into trade-specific Tasks (Masonry, Electrical, Plumbing).
- **The "Head" Responsibility**: Each Task is assigned to a specific "Head" (Lead Mestri/Plumber).
- **Mandatory Evidence**: Heads must upload high-quality video/image evidence *before* a task is verified. No evidence = No milestone completion.

## 📈 The Digital Trail
- **Capacity**: Optimized for ~300-500 evidence files per 18-month project stored securely in Firebase.
- **Security**: "Trust but Verify" policy enforced by Firebase App Check and granular Firestore rules, protecting project data from unauthorized access.

---

## 🤖 AI Agent Ecosystem (Mix Flow)
Our agents are specialized "Codex Assistants" designed to reduce manual oversight by 50%:

### 👷 Agent Vijay (Sales & Planning Expert)
- **Persona**: A savvy local contractor uncle who knows the Hyderabad market (Sangareddy to KPHB).
- **Function**: Captures project templates (Plot size, intent, floors) and provides floor-wise text plans and savvy quotes (anchoring to ₹1700/sqft base).
- **Disclaimer**: "AI can make mistakes. Trust but Verify. Human computations are final."

### 📦 Agent Material (Logistics & Store)
- **Persona**: A specialized vendor/seller with a 📦 badge.
- **Function**: Handles store queries from `material.json`, provide quotes for sand lorries, bricks, and ready-mix.
- **Fallback**: If items are unavailable, routes the user to WhatsApp for manual sourcing.

### 📋 Assigner (Territory Expansion)
- **Persona**: Efficiency-focused dispatcher.
- **Function**: Automatically matches worker skills to job descriptions and handles assignment in new locations where manual workforce is not yet established.

### 🎧 Support (Customer Care)
- **Persona**: Professional Indian construction support.
- **Function**: Chats via app, email, or WhatsApp. Fallback to human Admin if AI cannot resolve the query.

---

## 🧪 Testing & Validation
To ensure stability and "Trust but Verify" at the code level, run the following:

### Model Tests (Logic)
Verifies that job lifecycle, status transitions, and data structures are correct.
```bash
flutter test test/models/job_test.dart
```

### App Smoke Tests (UI)
Ensures the app launches, initializes providers, and displays the splash screen correctly.
```bash
flutter test test/widget_test.dart
```

---

## 🚀 Key Features

- **Role-based Authentication**: Secure login with Firebase Auth and Google Sign-In.
- **Job Management**: Unified "My Jobs" view for all roles with high-density cards.
- **Evidence Hub**: 100MB Video and Image player integration for site verification.
- **Project Dashboard**: Real-time overview for Supervisors with job management tools.
- **Integrated Payments**: Escrow-based milestone payments (Wiring in progress).

## 🛠 Technologies Used

- **Frontend**: [Flutter](https://flutter.dev/) (Portrait-locked, Material 3)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Firestore, Storage, App Check) & [Django](https://www.djangoproject.com/)
- **AI**: [OpenAI Assistants API](https://openai.com/) (Codex)
- **Media**: [Video Player](https://pub.dev/packages/video_player) & [Chewie](https://pub.dev/packages/chewie)

## 🏁 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Java 21 (for Firebase Emulators)
- Python 3.13 (for Django backend)

### Setup
1. Clone the repository.
2. Install dependencies: `flutter pub get`
3. Configure Firebase: Add `google-services.json` to `android/app/`.
4. Run: `flutter run`

---

## 🆘 Troubleshooting

### Java 21 Fix (Firebase Emulators)
```bash
brew install openjdk@21
echo 'export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Fix ApiException 10 (Google Sign-In)
Ensure SHA fingerprints are added to Firebase Console and a fresh `google-services.json` is in `android/app`.
