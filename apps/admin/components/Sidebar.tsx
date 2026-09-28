"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { clearSession } from "@/lib/session";

const LINKS = [
  { href: "/lessons", label: "Lessons" },
  { href: "/videos/new", label: "Videos" },
  { href: "/reports", label: "Reports" },
] as const;

export function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  return (
    <aside className="sidebar">
      <div>
        <span className="brand-mark">Baseline</span>
        <span className="brand-role">Admin</span>
      </div>
      <nav aria-label="Admin">
        <ul>
          {LINKS.map((link) => {
            const active =
              link.href === "/videos/new"
                ? pathname.startsWith("/videos")
                : pathname === link.href;
            return (
              <li key={link.href}>
                <Link
                  href={link.href}
                  className={active ? "active" : undefined}
                  aria-current={active ? "page" : undefined}
                >
                  {link.label}
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>
      <button
        className="secondary sign-out"
        type="button"
        onClick={() => {
          clearSession();
          router.push("/");
        }}
      >
        Sign out
      </button>
    </aside>
  );
}
