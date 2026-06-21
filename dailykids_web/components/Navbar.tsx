"use client";

import { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";

const links = [
  { href: "/", label: "Home" },
  { href: "/branches", label: "Branches" },
];

export default function Navbar() {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  // Close drawer on route change
  useEffect(() => {
    setOpen(false);
  }, [pathname]);

  // Lock body scroll when drawer is open
  useEffect(() => {
    document.body.style.overflow = open ? "hidden" : "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);

  const close = useCallback(() => setOpen(false), []);

  const isActive = (href: string) => {
    if (href === "/") return pathname === "/";
    return pathname.startsWith(href);
  };

  return (
    <>
      <header className="sticky top-0 z-50 bg-white/95 backdrop-blur-md border-b border-zinc-200">
        <nav className="max-w-6xl mx-auto flex items-center justify-between px-4 sm:px-6 py-3 sm:py-4">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2 sm:gap-3 shrink-0">
            <Image
              src="/DailyKids.png"
              alt="DailyKids"
              width={40}
              height={40}
              className="h-8 w-auto sm:h-10"
              priority
            />
            <span className="text-lg sm:text-xl font-bold text-teal-700">
              DailyKids
            </span>
          </Link>

          {/* Desktop nav links */}
          <div className="hidden md:flex items-center gap-6 text-sm font-medium">
            {links.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className={
                  isActive(link.href)
                    ? "text-teal-700 border-b-2 border-teal-600 pb-1"
                    : "text-zinc-600 hover:text-teal-700 transition-colors"
                }
              >
                {link.label}
              </Link>
            ))}
            <Link
              href="/admissions/apply"
              className="bg-teal-600 text-white px-5 py-2 rounded-full hover:bg-teal-700 transition-colors shadow-sm font-semibold"
            >
              Apply Now
            </Link>
          </div>

          {/* Mobile: Apply Now + Hamburger */}
          <div className="flex items-center gap-3 md:hidden">
            <Link
              href="/admissions/apply"
              className="bg-teal-600 text-white text-xs sm:text-sm px-4 py-1.5 rounded-full hover:bg-teal-700 transition-colors shadow-sm font-semibold"
            >
              Apply
            </Link>
            <button
              onClick={() => setOpen(true)}
              aria-label="Open menu"
              className="p-2 -mr-2 rounded-lg hover:bg-zinc-100 transition-colors focus:outline-none"
            >
              <svg
                className="w-6 h-6 text-zinc-700"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 6h16M4 12h16M4 18h16"
                />
              </svg>
            </button>
          </div>
        </nav>
      </header>

      {/* Mobile drawer overlay */}
      {open && (
        <div className="fixed inset-0 z-50 md:hidden">
          {/* Backdrop */}
          <div
            className="absolute inset-0 bg-black/40 backdrop-blur-sm transition-opacity duration-300"
            onClick={close}
          />

          {/* Drawer panel */}
          <div className="absolute top-0 right-0 h-full w-72 max-w-[85vw] bg-white shadow-2xl flex flex-col transition-transform duration-300 ease-in-out">
            {/* Drawer header */}
            <div className="flex items-center justify-between px-5 py-4 border-b border-zinc-100">
              <Link href="/" className="flex items-center gap-2" onClick={close}>
                <Image
                  src="/DailyKids.png"
                  alt="DailyKids"
                  width={32}
                  height={32}
                  className="h-7 w-auto"
                />
                <span className="text-base font-bold text-teal-700">
                  DailyKids
                </span>
              </Link>
              <button
                onClick={close}
                aria-label="Close menu"
                className="p-2 -mr-2 rounded-lg hover:bg-zinc-100 transition-colors focus:outline-none"
              >
                <svg
                  className="w-5 h-5 text-zinc-500"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>

            {/* Drawer links */}
            <div className="flex-1 py-6 px-5 space-y-1 overflow-y-auto">
              {links.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={close}
                  className={`block px-4 py-3 rounded-xl text-base font-medium transition-colors ${
                    isActive(link.href)
                      ? "bg-teal-50 text-teal-700"
                      : "text-zinc-700 hover:bg-zinc-50"
                  }`}
                >
                  {link.label}
                </Link>
              ))}
              <div className="pt-4">
                <Link
                  href="/admissions/apply"
                  onClick={close}
                  className="block w-full text-center bg-teal-600 text-white px-5 py-3 rounded-xl text-base font-semibold hover:bg-teal-700 transition-colors shadow-sm"
                >
                  Apply Now
                </Link>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
