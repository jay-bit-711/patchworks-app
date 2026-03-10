Exchange OAuth codes securely

This folder contains Firebase Cloud Functions that perform server-side OAuth token
exchanges. Keep `GOOGLE_OAUTH_CLIENT_SECRET` out of the repository and set it in
`functions/.env` or your deployment environment.

Endpoints

- `POST /exchange_oauth_code` - Accepts JSON `{ "code": "...", "redirect_uri": "..." }`
  and returns the token response from Google.

- `POST /refresh_oauth_token` - Accepts JSON `{ "refresh_token": "..." }`
  and returns a refreshed access token.

- `POST /revoke_oauth_token` - Accepts JSON `{ "token": "..." }` and revokes the token.

Setup & deploy

1. Create `functions/.env` (never commit) with:

```
GOOGLE_OAUTH_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
GOOGLE_OAUTH_CLIENT_SECRET=your_client_secret
```

2. From repo root deploy the functions:

```bash
cd functions
pip install -r requirements.txt
firebase deploy --only functions
```

3. Note the deployed function URLs from the `firebase deploy` output and update
   any client-side example (see `client_examples/exchange_code_example.js`).

Security notes

- Never include `client_secret` in client-side code or public repo commits.
- Limit who can call these endpoints (optional): add authentication/verification
  or restrict via IAM or other API gateway when deploying to production.
