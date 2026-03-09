# Patchworks

## Java 21 Fix (Firebase Emulators)

Run the following commands if `firebase emulators:start` fails with Java <21:

```bash
brew install openjdk@21
echo 'export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
java -version
```

## Fix ApiException 10 (Google Sign-In)

ApiException 10 fixed with SHA1 F9:50:95:E2:8A:6A:FD:18:47:A5:BA:A4:D8:34:CD:2F:53:31:FA:73 and SHA256 2A:36:05:2A:A5:2D:B8:A6:A0:CB:BA:76:47:23:4E:F1:6F:2B:6B:EE:97:C3:14:A4:27:51:1A:80:CA:EC:68:51 added to console.firebase.google.com/project/construction-agents/settings/general/android-apps > SHA fingerprints, new google-services.json downloaded to android/app, rebuild.

## Rebuild Test

Rebuild test: copy new google-services.json to android/app; flutter clean; flutter pub get; flutter build apk --release --target-platform android-arm64; adb install build/app/outputs/flutter-apk/app-release.apk
