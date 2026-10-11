import { createPublicKey, verify, type JsonWebKey, type KeyObject } from 'node:crypto';

type JwtClaims = {
  sub: string;
  email?: string;
  exp: number;
  iss: string;
  aud: string | string[];
};

const cache = new Map<string, { keys: Map<string, KeyObject>; expiresAt: number }>();

export async function verifyAppleIdentityToken(token: string): Promise<{ sub: string; email?: string } | null> {
  const audience = process.env.APPLE_AUDIENCE ?? 'com.baselinetennis.baseline';
  return verifyIdentityToken(token, {
    jwksUrl: 'https://appleid.apple.com/auth/keys',
    issuers: ['https://appleid.apple.com'],
    audience,
    algorithms: new Set(['ES256', 'RS256']),
  });
}

export async function verifyGoogleIdToken(token: string): Promise<{ sub: string; email?: string } | null> {
  const audience = process.env.GOOGLE_CLIENT_ID ?? '283168836629-gicgf5vp90r2q7d8oimf0dejj53um4h9.apps.googleusercontent.com';
  return verifyIdentityToken(token, {
    jwksUrl: 'https://www.googleapis.com/oauth2/v3/certs',
    issuers: ['https://accounts.google.com', 'accounts.google.com'],
    audience,
    algorithms: new Set(['RS256']),
  });
}

async function verifyIdentityToken(
  token: string,
  options: { jwksUrl: string; issuers: string[]; audience: string; algorithms: Set<string> },
): Promise<{ sub: string; email?: string } | null> {
  const parts = token.split('.');
  if (parts.length !== 3) return null;
  const [encodedHeader, encodedPayload, encodedSignature] = parts;
  if (!encodedHeader || !encodedPayload || !encodedSignature) return null;
  let header: { alg?: string; kid?: string };
  let payload: JwtClaims;
  try {
    header = JSON.parse(decode(encodedHeader).toString('utf8')) as { alg?: string; kid?: string };
    payload = JSON.parse(decode(encodedPayload).toString('utf8')) as JwtClaims;
  } catch {
    return null;
  }
  if (!header.alg || !header.kid || !options.algorithms.has(header.alg)) return null;
  if (!payload.sub || payload.exp * 1000 <= Date.now()) return null;
  if (!options.issuers.includes(payload.iss)) return null;
  const audiences = Array.isArray(payload.aud) ? payload.aud : [payload.aud];
  if (!audiences.includes(options.audience)) return null;
  const key = await keyFor(options.jwksUrl, header.kid);
  if (!key) return null;
  const signed = Buffer.from(`${encodedHeader}.${encodedPayload}`);
  const signature = decode(encodedSignature);
  const ok = header.alg === 'ES256'
    ? verify('sha256', signed, { key, dsaEncoding: 'ieee-p1363' }, signature)
    : verify('RSA-SHA256', signed, key, signature);
  if (!ok) return null;
  const email = typeof payload.email === 'string' ? payload.email : undefined;
  return { sub: payload.sub, email };
}

async function keyFor(url: string, kid: string): Promise<KeyObject | null> {
  const now = Date.now();
  const cached = cache.get(url);
  if (cached && cached.expiresAt > now) return cached.keys.get(kid) ?? null;
  const response = await fetch(url);
  if (!response.ok) return null;
  const body = (await response.json()) as { keys?: JsonWebKey[] };
  const keys = new Map<string, KeyObject>();
  for (const jwk of body.keys ?? []) {
    if (!jwk.kid || typeof jwk.kid !== 'string') continue;
    keys.set(jwk.kid, createPublicKey({ key: jwk, format: 'jwk' }));
  }
  cache.set(url, { keys, expiresAt: now + 60 * 60 * 1000 });
  return keys.get(kid) ?? null;
}

function decode(value: string): Buffer {
  const padded = value.replace(/-/g, '+').replace(/_/g, '/');
  const pad = padded.length % 4 === 0 ? '' : '='.repeat(4 - (padded.length % 4));
  return Buffer.from(padded + pad, 'base64');
}
