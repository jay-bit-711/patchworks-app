# Patchworks

## 🎯 Vision & Mission

**Motto:** *Trust but Verify.*

**Vision:** Providing a digital trail of their end-to-end home needs.

**Mission:** Our mission is to empower construction teams with an intelligent, mobile-first ecosystem that simplifies project complexity. By integrating real-time site data, automated documentation via specialized AI agents, and secure financial tools, we ensure every project is delivered with precision and accountability.

---

Patchworks is a Flutter-based application designed for construction management and coordination. It leverages Firebase for backend services and provides a suite of tools for job creation, evidence capture, and real-time communication with specialized agents.

## Key Features

- **Role-based Authentication**: Secure login with Firebase Auth and Google Sign-In.
- **Job Management**: Create and track jobs directly from the mobile app.
- **Evidence Capture**: Document project progress with image and data capture.
- **Project Dashboard**: Real-time overview of project status and metrics.
- **AI-Powered Agent Chat**: Interactive chat interfaces with specialized agents:
  - **Vijay**: General project coordination.
  - **Material Agent**: Logistics and material tracking.
  - **Document Tracker**: automated document and compliance monitoring.
- **Integrated Payments**: Support for transactions via Razorpay.
- **Location Services**: Geolocation and Google Maps integration for site tracking.

## Technologies Used

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Firestore, Functions, Storage, App Check)
- **Maps**: [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- **Payments**: [Razorpay Flutter](https://pub.dev/packages/razorpay_flutter)
- **PDF Generation**: [pdf](https://pub.dev/packages/pdf)

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Java 21 (required for Firebase Emulators)
- Android Studio / VS Code with Flutter extensions

### Setup

1.  Clone the repository.
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Configure Firebase:
    - Add `google-services.json` to `android/app/`.
    - Ensure SHA fingerprints are correctly set in the Firebase Console.
4.  Run the application:
    ```bash
    flutter run
    ```

---

## Troubleshooting

### Java 21 Fix (Firebase Emulators)

Run the following commands if `firebase emulators:start` fails with Java <21:

```bash
brew install openjdk@21
echo 'export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
java -version
```

### Fix ApiException 10 (Google Sign-In)

ApiException 10 fixed with SHA1 `F9:50:95:E2:8A:6A:FD:18:47:A5:BA:A4:D8:34:CD:2F:53:31:FA:73` and SHA256 `2A:36:05:2A:A5:2D:B8:A6:A0:CB:BA:76:47:23:4E:F1:6F:2B:6B:EE:97:C3:14:A4:27:51:1A:80:CA:EC:68:51` added to console.firebase.google.com > Project Settings > General > SHA fingerprints. Download the new `google-services.json` to `android/app` and rebuild.

### Rebuild Test

To perform a clean rebuild and test on a device:
```bash
flutter clean
flutter pub get
flutter build apk --release --target-platform android-arm64
adb install build/app/outputs/flutter-apk/app-release.apk
```
