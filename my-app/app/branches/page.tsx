import Link from "next/link";

const branches = [
  {
    name: "Ambalangoda",
    address: "123 Galle Road, Ambalangoda",
    phone: "+94 91 225 6789",
    email: "ambalangoda@kinderlog.com",
    description:
      "Our flagship campus featuring state-of-the-art classrooms, a vibrant outdoor play area, and a dedicated arts & crafts studio.",
    facilities: [
      "Air-conditioned classrooms",
      "Outdoor playground",
      "Arts & crafts studio",
      "Nap room",
      "CCTV security",
      "Medical room",
    ],
    classes: ["FS1", "FS2", "Yellow", "Green"],
  },
  {
    name: "Hikkaduwa",
    address: "45 Beach Road, Hikkaduwa",
    phone: "+94 91 226 1234",
    email: "hikkaduwa@kinderlog.com",
    description:
      "Our coastal campus offering a unique learning environment with a nature garden, music room, and spacious classrooms with ocean views.",
    facilities: [
      "Nature garden",
      "Music & movement room",
      "Spacious classrooms",
      "Library corner",
      "CCTV security",
      "Medical room",
    ],
    classes: ["FS1", "FS2"],
  },
];

export default function BranchesPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <header className="sticky top-0 z-50 bg-white/90 backdrop-blur border-b border-zinc-200">
        <nav className="max-w-6xl mx-auto flex items-center justify-between px-6 py-4">
          <Link href="/" className="flex items-center gap-3">
            <span className="text-3xl">🧒</span>
            <span className="text-xl font-bold text-teal-700">KinderLog</span>
          </Link>
          <div className="flex items-center gap-6 text-sm font-medium">
            <Link href="/" className="text-zinc-600 hover:text-teal-700 transition-colors">
              Home
            </Link>
            <Link href="/branches" className="text-teal-700 border-b-2 border-teal-600 pb-1">
              Branches
            </Link>
            <Link href="/gallery" className="text-zinc-600 hover:text-teal-700 transition-colors">
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
          Our Branches
        </h1>
        <p className="text-center text-zinc-500 mb-12 max-w-lg mx-auto">
          Two convenient locations, each offering a safe, nurturing environment
          with certified educators.
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {branches.map((b) => (
            <div
              key={b.name}
              className="bg-white rounded-2xl p-8 border border-zinc-200 hover:shadow-lg transition-shadow"
            >
              <h2 className="text-2xl font-bold text-teal-700 mb-3">{b.name}</h2>
              <p className="text-zinc-500 mb-4">{b.description}</p>
              <div className="space-y-2 text-sm text-zinc-600 mb-4">
                <p>📍 {b.address}</p>
                <p>📞 {b.phone}</p>
                <p>✉️ {b.email}</p>
              </div>
              <p className="text-sm font-semibold text-zinc-700 mb-2">
                Classes: {b.classes.join(", ")}
              </p>
              <div className="flex flex-wrap gap-2">
                {b.facilities.map((f) => (
                  <span
                    key={f}
                    className="text-xs bg-teal-50 text-teal-700 px-3 py-1 rounded-full font-medium"
                  >
                    {f}
                  </span>
                ))}
              </div>
            </div>
          ))}
        </div>
      </main>

      <footer className="bg-zinc-900 text-zinc-400 py-12">
        <div className="max-w-6xl mx-auto px-6 text-center text-sm">
          <p>
            <span className="text-white font-semibold">KinderLog Preschool</span>{" "}
            &copy; {new Date().getFullYear()}
          </p>
        </div>
      </footer>
    </div>
  );
}
