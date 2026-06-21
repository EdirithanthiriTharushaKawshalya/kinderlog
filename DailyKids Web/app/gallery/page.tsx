import Link from "next/link";
import Image from "next/image";

const galleryItems = [
  { caption: "Outdoor Playground — Ambalangoda", category: "facilities" },
  { caption: "Nature Garden — Hikkaduwa", category: "facilities" },
  { caption: "Annual Sports Day 2026", category: "events" },
  { caption: "Art Exhibition — FS1 Students", category: "events" },
  { caption: "Reading Corner — FS2 Classroom", category: "classroom" },
  { caption: "Group Activity — Yellow Class", category: "classroom" },
  { caption: "Fire Drill Practice", category: "safety" },
  { caption: "CCTV Monitoring Station", category: "safety" },
  { caption: "Music & Movement Session", category: "classroom" },
  { caption: "Outdoor Play — Hikkaduwa", category: "facilities" },
  { caption: "Year-End Concert 2025", category: "events" },
  { caption: "First Aid Training", category: "safety" },
];

const categories = ["All", "facilities", "events", "classroom", "safety"] as const;

export default function GalleryPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <header className="sticky top-0 z-50 bg-white/90 backdrop-blur border-b border-zinc-200">
        <nav className="max-w-6xl mx-auto flex items-center justify-between px-6 py-4">
          <Link href="/" className="flex items-center gap-3">
            <Image src="/DailyKids.png" alt="DailyKids" width={40} height={40} className="h-10 w-auto" />
            <span className="text-xl font-bold text-teal-700">DailyKids</span>
          </Link>
          <div className="flex items-center gap-6 text-sm font-medium">
            <Link href="/" className="text-zinc-600 hover:text-teal-700 transition-colors">
              Home
            </Link>
            <Link href="/branches" className="text-zinc-600 hover:text-teal-700 transition-colors">
              Branches
            </Link>
            <Link href="/gallery" className="text-teal-700 border-b-2 border-teal-600 pb-1">
              Gallery
            </Link>
            <Link
              href="/admissions/apply"
              className="bg-teal-600 text-white px-5 py-2 rounded-full hover:bg-teal-700 transition-colors"
            >
              Apply Now
            </Link>
          </div>
        </nav>
      </header>

      <main className="flex-1 max-w-6xl mx-auto px-6 py-16 w-full">
        <h1 className="text-4xl font-bold text-zinc-800 mb-4 text-center">
          Virtual Tour & Gallery
        </h1>
        <p className="text-center text-zinc-500 mb-12 max-w-lg mx-auto">
          Explore our facilities, events, classrooms, and safety standards.
        </p>

        {/* Category filter */}
        <div className="flex justify-center gap-3 mb-10 flex-wrap">
          {categories.map((cat) => (
            <a
              key={cat}
              href={cat === "All" ? "/gallery" : `/gallery?cat=${cat}`}
              className="px-4 py-2 rounded-full text-sm font-medium border border-zinc-300 text-zinc-600 hover:bg-teal-50 hover:text-teal-700 hover:border-teal-300 transition-colors"
            >
              {cat === "All" ? "All" : cat.charAt(0).toUpperCase() + cat.slice(1)}
            </a>
          ))}
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {galleryItems.map((item) => (
            <div
              key={item.caption}
              className="bg-white rounded-xl p-6 text-center border border-zinc-200 hover:shadow-md transition-shadow"
            >
              <span className="text-4xl block mb-3">🖼️</span>
              <p className="text-sm text-zinc-700 font-medium mb-1">{item.caption}</p>
              <span className="text-xs text-zinc-400 uppercase tracking-wide">
                {item.category}
              </span>
            </div>
          ))}
        </div>
      </main>

      <footer className="bg-white border-t border-zinc-200 text-zinc-500 py-12">
        <div className="max-w-6xl mx-auto px-6 text-center text-sm">
          <p>
            <span className="text-zinc-800 font-semibold">DailyKids Preschool</span>{" "}
            &copy; {new Date().getFullYear()}
          </p>
        </div>
      </footer>
    </div>
  );
}
