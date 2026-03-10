Steps to patch APK with your google-services.json

1) Prereqs (install on your mac):
   - apktool (https://ibotpeaches.github.io/Apktool/)
   - Java 11+
   - apksigner (Android build-tools) or jarsigner
   - python3

2) Copy your APK and `google-services.json` to a working folder.

3) From that folder run the script in this repo:

```bash
chmod +x /path/to/patch_apk.sh
/path/to/patch_apk.sh /full/path/to/app-debug.apk /full/path/to/google-services.json
```

4) The script will decompile, generate a `values.xml` from `google-services.json`, replace the first `res/values/values.xml` found, rebuild and sign the APK (using your debug keystore by default).

Notes & caveats:
- The script only updates Android resource strings. If the app embeds Firebase configuration directly in code or other resources, additional edits will be required.
- After rebuilding you should test the APK on a device and check `adb logcat` for Firebase initialization and auth events.
- If you prefer, instead of using the script you can copy the file `decompile_helpers/new_firebase_values.xml` into the decompiled `res/values/values.xml` before rebuilding with apktool.

If you want me to attempt an automated decompile/edit/repack here, I can only write scripts and files. I cannot run `apktool` or `apksigner` in this environment; please run the script locally and paste failures or logs here and I'll iterate.
