#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 /path/to/app-debug.apk /path/to/google-services.json"
  exit 2
fi

APK_PATH="$1"
GS_JSON="$2"
OUT_APK="patched-app.apk"
TMPDIR="$(mktemp -d)"
APKTOOL_CMD="apktool"
APKSIGNER_CMD="$(command -v apksigner || true)"
JARSIGNER_CMD="$(command -v jarsigner || true)"
KEYSTORE="${KEYSTORE:-$HOME/.android/debug.keystore}"
KEYPASS="${KEYPASS:-android}"
ALIAS="${ALIAS:-androiddebugkey}"

echo "Working in $TMPDIR"
cd "$TMPDIR"

echo "Decompiling APK..."
if command -v "$APKTOOL_CMD" >/dev/null 2>&1; then
  $APKTOOL_CMD d -f "$APK_PATH" -o decompiled
else
  echo "apktool not found in PATH. Please install apktool or set APKTOOL_JAR env to jar path." >&2
  exit 3
fi

# Generate values XML from google-services.json
python3 - <<PY > new_firebase_values.xml
import json,sys
g=json.load(open("$GS_JSON"))
pi=g.get("project_info",{})
client=None
for c in g.get("client",[]):
    if 'client_info' in c:
        client=c
        break
if not client:
    print("No client found",file=sys.stderr); sys.exit(2)
ci=client["client_info"]
api_key = client.get("api_key",[{}])[0].get("current_key","")
# try to find web client
web_client=None
for oc in client.get('oauth_client',[]):
    if oc.get('client_type')==3:
        web_client=oc
        break
if web_client is None:
    web_client = client.get('oauth_client',[{}])[0]

print('<?xml version="1.0" encoding="utf-8"?>')
print('<resources>')
print(f'    <string name="google_app_id">{ci.get("mobilesdk_app_id","")}</string>')
print(f'    <string name="gcm_defaultSenderId">{pi.get("project_number","")}</string>')
print(f'    <string name="default_web_client_id">{web_client.get("client_id","")}</string>')
print(f'    <string name="google_api_key">{api_key}</string>')
print(f'    <string name="google_storage_bucket">{pi.get("storage_bucket","")}</string>')
print(f'    <string name="project_id">{pi.get("project_id","")}</string>')
print('</resources>')
PY

# Find values dir
VALUES_DIR="$(find decompiled -type d -path '*/res/values*' | head -n1)"
if [ -z "$VALUES_DIR" ]; then
  echo "Could not find res/values directory in decompiled APK" >&2
  exit 4
fi

echo "Backing up original values.xml and replacing with generated values..."
if [ -f "$VALUES_DIR/values.xml" ]; then
  cp "$VALUES_DIR/values.xml" "$VALUES_DIR/values.xml.bak" || true
fi
mv new_firebase_values.xml "$VALUES_DIR/values.xml"

echo "Rebuilding APK..."
$APKTOOL_CMD b decompiled -o rebuilt.apk

# Sign
if [ -n "$APKSIGNER_CMD" ]; then
  echo "Signing with apksigner..."
  $APKSIGNER_CMD sign --ks "$KEYSTORE" --ks-pass pass:"$KEYPASS" --key-pass pass:"$KEYPASS" --out "$OUT_APK" rebuilt.apk
  echo "Signed APK: $TMPDIR/$OUT_APK"
elif [ -n "$JARSIGNER_CMD" ]; then
  echo "Signing with jarsigner..."
  cp rebuilt.apk unsigned.apk
  $JARSIGNER_CMD -keystore "$KEYSTORE" -storepass "$KEYPASS" -keypass "$KEYPASS" unsigned.apk "$ALIAS"
  if command -v zipalign >/dev/null 2>&1; then
    zipalign -v -p 4 unsigned.apk "$OUT_APK"
  else
    mv unsigned.apk "$OUT_APK"
  fi
  echo "Signed APK: $TMPDIR/$OUT_APK"
else
  echo "No signing tool found. Rebuilt APK available as rebuilt.apk (sign manually)." >&2
  mv rebuilt.apk "$OUT_APK"
fi

echo "Done. Patched APK at: $TMPDIR/$OUT_APK"

echo "Tip: copy the APK out of the temp folder: cp $TMPDIR/$OUT_APK /path/to/destination"
