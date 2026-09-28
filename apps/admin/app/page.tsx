"use client";

import { FormEvent, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { hasSession, setSession } from "@/lib/session";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    if (hasSession()) {
      router.replace("/lessons");
    }
  }, [router]);

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (email.trim() === "") {
      setError("Enter an email.");
      return;
    }
    if (password.trim() === "") {
      setError("Enter a password to pass the development gate.");
      return;
    }
    setSession();
    router.push("/lessons");
  }

  return (
    <main className="login-screen">
      <section className="login-card">
        <p className="login-kicker">Baseline</p>
        <h1>Admin</h1>
        <p className="gate-copy">
          This is a development gate. Any non-empty password sets a local
          session flag in this browser. It does not check a real account.
        </p>
        <form className="login-form" onSubmit={onSubmit}>
          <label className="field">
            <span>Email</span>
            <input
              type="email"
              name="email"
              autoComplete="username"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              required
            />
          </label>
          <label className="field">
            <span>Dev password</span>
            <input
              type="password"
              name="password"
              autoComplete="current-password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              required
            />
          </label>
          {error ? <p className="form-error">{error}</p> : null}
          <button className="primary" type="submit">
            Enter admin
          </button>
        </form>
      </section>
    </main>
  );
}
