import { createHash, randomBytes, timingSafeEqual } from 'node:crypto';

export function newToken(): string {
  return randomBytes(32).toString('base64url');
}

export function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

export function tokensMatch(presentedHash: string, expectedHash: string): boolean {
  const left = Buffer.from(presentedHash);
  const right = Buffer.from(expectedHash);
  if (left.length !== right.length) return false;
  return timingSafeEqual(left, right);
}
