OAuth & Google Picker — Setup, examples, and security notes

Quick overview
- Use the OAuth web client ID for client-side interactions (sign-in, user consent).
- Use the API key (developerKey) and project number (appId) when initializing Google Picker.
- Keep the OAuth client secret server-side and use the `exchange_oauth_code` Cloud Function to exchange auth codes for tokens.

Files added in this repo
- `client_examples/oauth_client_example.html`: simple page that starts the OAuth authorization code flow.
- `client_examples/exchange_code_example.js`: example POST to the `exchange_oauth_code` Cloud Function.

Values discovered in this project
- OAuth web client ID: `868512832982-greilgo7b8tqeo2s202ufubd4i5lbfm4.apps.googleusercontent.com`
- API key (developerKey): `AIzaSyBWjNqaBJfISUMgyGYZX93XoqBbpB5Y9JA`
- App ID / Project number (use with Picker.setAppId): `868512832982`

Setup checklist (Google Cloud / Firebase)
1. In Google Cloud Console enable the **Google Drive API** for the project.
2. Configure the OAuth consent screen (External or Internal) and add Drive scopes:
   - `https://www.googleapis.com/auth/drive.readonly`
   - `https://www.googleapis.com/auth/drive.file`
3. In Credentials, configure a **Web application** OAuth client and ensure:
   - Authorized JavaScript origins include `http://localhost`, `http://localhost:5000`, and `https://construction-agents.firebaseapp.com`.
   - Authorized redirect URI includes `https://construction-agents.firebaseapp.com/__/auth/handler`.
4. In Firebase console, confirm your web app has the API key and client ID configured.

Local testing
- Open `client_examples/oauth_client_example.html` in a browser to start the consent flow.
- After redirect, copy the `code` query parameter and run the `exchange_code_example.js` (in a simple page or Node) to POST to the Cloud Function.

Deploying the Cloud Function
1. Ensure `functions/.env` contains `GOOGLE_OAUTH_CLIENT_ID` and `GOOGLE_OAUTH_CLIENT_SECRET` and is not committed to public repos.
2. From repo root run:

```bash
cd functions
pip install -r requirements.txt
firebase deploy --only functions
```

3. Note the deployed HTTPS URL for `exchange_oauth_code` and replace `YOUR_CLOUD_FUNCTION_URL` in `client_examples/exchange_code_example.js`.

Security notes
- Never include `client_secret` in client-side code or public repo commits. Keep it in `functions/.env` or a secrets manager.
- If the `client_secret` was exposed, rotate it in Google Cloud Console immediately.
- Use `access_type=offline` and `prompt=consent` only when you explicitly need refresh tokens.

Flutter integration notes
- For Picker on web the app uses `GooglePickerService` (web implementation) and requires an OAuth access token with Drive scopes. The `AuthService.signInWithGoogleAndGetAccessToken()` returns an access token when available.
- Alternatively, for server-side token flows use the auth-code flow and `exchange_oauth_code` Cloud Function.
