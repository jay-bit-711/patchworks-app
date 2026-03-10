// Example: exchange an OAuth authorization code with your Cloud Function
// Replace `YOUR_CLOUD_FUNCTION_URL` with the URL from `firebase deploy` output.

async function exchangeCode(code) {
  const fnUrl = 'https://YOUR_CLOUD_FUNCTION_URL/exchange_oauth_code'; // replace

  const resp = await fetch(fnUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      code: code,
      redirect_uri: 'https://construction-agents.firebaseapp.com/__/auth/handler'
    }),
  });

  if (!resp.ok) {
    const text = await resp.text();
    throw new Error('Token exchange failed: ' + text);
  }

  const data = await resp.json();
  console.log('Token response:', data);
  return data;
}

// Usage example: after receiving `code` from redirect, call:
// exchangeCode('AUTH_CODE_FROM_QUERY').then(console.log).catch(console.error);
