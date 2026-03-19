// supabase/functions/_shared/fcm.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Minimal base64url encoding
function encodeBase64Url(source: string | Uint8Array): string {
  let encoded = typeof source === 'string'
    ? btoa(unescape(encodeURIComponent(source)))
    : btoa(String.fromCharCode(...source));
  return encoded.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

// Memory Cache for the Token
let cachedToken: string | null = null;
let tokenExpirationTime: number = 0;

export async function getFCMAccessToken(): Promise<string> {
  // Return cached token if still valid (buffer of 5 minutes)
  if (cachedToken && Date.now() < tokenExpirationTime - 300000) {
    return cachedToken;
  }

  const serviceAccountStr = Deno.env.get('GOOGLE_SERVICE_ACCOUNT_JSON');
  if (!serviceAccountStr) throw new Error("GOOGLE_SERVICE_ACCOUNT_JSON is missing");

  const credentials = JSON.parse(serviceAccountStr);

  const header = { alg: 'RS256', typ: 'JWT' };
  const iat = Math.floor(Date.now() / 1000);
  const exp = iat + 3600; // 1 hour max

  const payload = {
    iss: credentials.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp,
    iat
  };

  const encodedHeader = encodeBase64Url(JSON.stringify(header));
  const encodedPayload = encodeBase64Url(JSON.stringify(payload));
  const signatureInput = `${encodedHeader}.${encodedPayload}`;

  // Extract the private key properly
  const pemHeader = "-----BEGIN PRIVATE KEY-----";
  const pemFooter = "-----END PRIVATE KEY-----";
  const pemContents = credentials.private_key.replace(pemHeader, "").replace(pemFooter, "").replace(/\n/g, "");

  const binaryDerString = atob(pemContents);
  const binaryDer = new Uint8Array(binaryDerString.length);
  for (let i = 0; i < binaryDerString.length; i++) {
    binaryDer[i] = binaryDerString.charCodeAt(i);
  }

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer.buffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signatureBuffer = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signatureInput)
  );

  const encodedSignature = encodeBase64Url(new Uint8Array(signatureBuffer));
  const signedJwt = `${signatureInput}.${encodedSignature}`;

  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${signedJwt}`
  });

  const data = await tokenResponse.json();
  if (!tokenResponse.ok) throw new Error(`FCM Auth Error: ${JSON.stringify(data)}`);

  cachedToken = data.access_token;
  tokenExpirationTime = Date.now() + (data.expires_in * 1000);

  return cachedToken!;
}

export async function dispatchToUser(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  title: string,
  body: string,
  data?: Record<string, string>
): Promise<void> {
  const { data: tokens } = await supabase
    .from('fcm_tokens')
    .select('token')
    .eq('user_id', userId);

  if (!tokens || tokens.length === 0) return;

  const accessToken = await getFCMAccessToken();
  const FCM_URL = `https://fcm.googleapis.com/v1/projects/${Deno.env.get('FCM_PROJECT_ID')}/messages:send`;

  for (const { token } of tokens) {
    const response = await fetch(FCM_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data: data ?? {},
          android: {
            priority: 'high',
            notification: { channel_id: 'amandier_main' }
          }
        }
      })
    });

    // We log failures but do not block the loop
    if (!response.ok) {
       console.error(`[FCM Dispatch Error for ${userId}]:`, await response.text());
    }
  }
}
