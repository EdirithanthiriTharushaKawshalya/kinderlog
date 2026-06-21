import Link from "next/link";
import Image from "next/image";

export default function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className="bg-white border-t border-zinc-200 text-zinc-500 py-12">
      <div className="max-w-6xl mx-auto px-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-10">
          {/* Brand Info */}
          <div>
            <Link href="/" className="flex items-center gap-2.5 mb-4">
              <Image
                src="/DailyKids.png"
                alt="DailyKids"
                width={32}
                height={32}
                className="h-8 w-auto"
              />
              <span className="text-lg font-bold text-teal-700">DailyKids</span>
            </Link>
            <p className="text-sm text-zinc-500 leading-relaxed">
              Nurturing Young Minds Since 2020. Quality early childhood
              education in a safe, loving environment.
            </p>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="text-zinc-800 font-semibold mb-4 text-sm uppercase tracking-wider">
              Quick Links
            </h4>
            <ul className="space-y-2 text-sm">
              <li>
                <Link
                  href="/branches"
                  className="text-zinc-500 hover:text-teal-600 transition-colors"
                >
                  Our Branches
                </Link>
              </li>
              <li>
                <Link
                  href="/admissions/apply"
                  className="text-zinc-500 hover:text-teal-600 transition-colors"
                >
                  Apply Online
                </Link>
              </li>
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h4 className="text-zinc-800 font-semibold mb-4 text-sm uppercase tracking-wider">
              Contact Us
            </h4>
            <ul className="space-y-2.5 text-sm">
              <li className="flex items-start gap-2">
                <span className="text-base">📍</span>
                <span>Ambalangoda &middot; Hikkaduwa</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="text-base">📞</span>
                <a
                  href="tel:+94912256789"
                  className="hover:text-teal-600 transition-colors"
                >
                  +94 91 225 6789
                </a>
              </li>
              <li className="flex items-center gap-2">
                <span className="text-base">✉️</span>
                <a
                  href="mailto:info@dailykids.com"
                  className="hover:text-teal-600 transition-colors"
                >
                  info@dailykids.com
                </a>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="border-t border-zinc-100 pt-6 text-center text-xs text-zinc-400">
          <p>&copy; {year} DailyKids Preschool. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}
