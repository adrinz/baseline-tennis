const SESSION_KEY = "baseline-admin-session";

export function hasSession(): boolean {
  if (typeof window === "undefined") {
    return false;
  }
  return window.localStorage.getItem(SESSION_KEY) === "1";
}

export function setSession(): void {
  window.localStorage.setItem(SESSION_KEY, "1");
}

export function clearSession(): void {
  window.localStorage.removeItem(SESSION_KEY);
}
