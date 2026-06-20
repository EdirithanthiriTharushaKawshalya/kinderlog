import Link from "next/link";

const features = [
  { icon: "🎓", title: "Qualified Teachers", desc: "Montessori & ECE certified educators" },
  { icon: "🔒", title: "Safe Environment", desc: "CCTV monitoring & secure access control" },
  { icon: "🍎", title: "Nutritious Meals", desc: "Dietician-approved daily menu" },
  { icon: "🎨", title: "Arts & Music", desc: "Daily creative expression sessions" },
];

const testimonials = [
  {
    parentName: "Nimal Perera",
    childName: "Amaya",
    quote:
      "KinderLog has been a wonderful experience for our daughter. The teachers are caring and communicative.",
    rating: 5,
  },
  {
    parentName: "Sarah Johnson",
    childName: "Emma",
    quote:
      "The allergy safety protocols gave us peace of mind. Emma loves going to school every day!",
    rating: 5,
  },
  {
    parentName: "Raj Patel",
    childName: "Aanya",
    quote:
      "As newcomers, the staff made the transition so smooth. Highly recommend the Hikkaduwa branch.",
    rating: 4,
  },
];

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

const galleryItems = [
  { caption: "Outdoor Playground — Ambalangoda", category: "facilities" },
  { caption: "Nature Garden — Hikkaduwa", category: "facilities" },
  { caption: "Annual Sports Day 2026", category: "events" },
  { caption: "Art Exhibition — FS1 Students", category: "events" },
  { caption: "Reading Corner — FS2 Classroom", category: "classroom" },
  { caption: "Group Activity — Yellow Class", category: "classroom" },
  { caption: "Fire Drill Practice", category: "safety" },
  { caption: "CCTV Monitoring Station", category: "safety" },
];

export default function Home() {
  return (
    <div className="flex flex-col">
      {/* Header / Navigation */}
      <header className="sticky top-0 z-50 bg-white/90 backdrop-blur border-b border-zinc-200">
        <nav className="max-w-6xl mx-auto flex items-center justify-between px-6 py-4">
          <Link href="/" className="flex items-center gap-3">
            <span className="text-3xl">🧒</span>
            <span className="text-xl font-bold text-teal-700">KinderLog</span>
          </Link>
          <div className="flex items-center gap-6 text-sm font-medium">
            <Link href="/" className="text-teal-700 border-b-2 border-teal-600 pb-1">
              Home
            </Link>
            <Link href="/branches" className="text-zinc-600 hover:text-teal-700 transition-colors">
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

      {/* Hero */}
      <section className="bg-gradient-to-br from-teal-600 to-teal-800 text-white">
        <div className="max-w-6xl mx-auto px-6 py-24 text-center">
          <span className="text-6xl mb-6 block">🧒</span>
          <h1 className="text-5xl font-bold mb-4 tracking-tight">
            KinderLog Preschool
          </h1>
          <p className="text-xl text-teal-100 mb-2">Nurturing Young Minds Since 2020</p>
          <p className="text-teal-200 max-w-xl mx-auto mb-10">
            Every child is unique. Our play-based curriculum fosters curiosity,
            creativity, and confidence in a safe, nurturing environment.
          </p>
          <div className="flex gap-4 justify-center">
            <Link
              href="/admissions/apply"
              className="bg-white text-teal-700 px-8 py-3 rounded-full font-semibold hover:bg-teal-50 transition-colors"
            >
              Start Application
            </Link>
            <Link
              href="/branches"
              className="border-2 border-white/40 text-white px-8 py-3 rounded-full font-semibold hover:bg-white/10 transition-colors"
            >
              Our Branches
            </Link>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="max-w-6xl mx-auto px-6 py-20">
        <h2 className="text-3xl font-bold text-center mb-12 text-zinc-800">
          Why Choose KinderLog?
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {features.map((f) => (
            <div
              key={f.title}
              className="bg-white rounded-2xl p-6 border border-zinc-200 text-center hover:shadow-lg transition-shadow"
            >
              <span className="text-4xl block mb-4">{f.icon}</span>
              <h3 className="font-bold text-zinc-800 mb-1">{f.title}</h3>
              <p className="text-sm text-zinc-500">{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Testimonials */}
      <section className="bg-white py-20">
        <div className="max-w-6xl mx-auto px-6">
          <h2 className="text-3xl font-bold text-center mb-12 text-zinc-800">
            What Parents Say
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {testimonials.map((t) => (
              <div
                key={t.parentName}
                className="bg-zinc-50 rounded-2xl p-6 border border-zinc-200"
              >
                <div className="flex gap-1 mb-3">
                  {Array.from({ length: 5 }).map((_, i) => (
                    <span key={i} className="text-amber-500">
                      {i < t.rating ? "★" : "☆"}
                    </span>
                  ))}
                </div>
                <p className="text-zinc-600 italic mb-4">&ldquo;{t.quote}&rdquo;</p>
                <p className="text-sm text-zinc-500">
                  — {t.parentName} ({t.childName})
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Fast Facts / Branches Preview */}
      <section className="max-w-6xl mx-auto px-6 py-20">
        <h2 className="text-3xl font-bold text-center mb-4 text-zinc-800">
          Our Branches
        </h2>
        <p className="text-center text-zinc-500 mb-12 max-w-lg mx-auto">
          Two convenient locations to serve your family, each with unique
          facilities and certified educators.
        </p>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {branches.map((b) => (
            <div
              key={b.name}
              className="bg-white rounded-2xl p-8 border border-zinc-200 hover:shadow-lg transition-shadow"
            >
              <h3 className="text-2xl font-bold text-teal-700 mb-3">{b.name}</h3>
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
      </section>

      {/* Gallery Preview */}
      <section className="bg-white py-20">
        <div className="max-w-6xl mx-auto px-6">
          <h2 className="text-3xl font-bold text-center mb-4 text-zinc-800">
            Virtual Tour & Gallery
          </h2>
          <p className="text-center text-zinc-500 mb-12">
            Explore our facilities, events, and classrooms.
          </p>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {galleryItems.slice(0, 8).map((item) => (
              <div
                key={item.caption}
                className="bg-zinc-100 rounded-xl p-6 text-center hover:bg-teal-50 transition-colors"
              >
                <span className="text-3xl block mb-2">🖼️</span>
                <p className="text-xs text-zinc-600 font-medium">{item.caption}</p>
                <span className="text-[10px] text-zinc-400 uppercase">{item.category}</span>
              </div>
            ))}
          </div>
          <div className="text-center mt-8">
            <Link
              href="/gallery"
              className="text-teal-600 font-semibold hover:underline"
            >
              View Full Gallery →
            </Link>
          </div>
        </div>
      </section>

      {/* Admissions CTA */}
      <section className="bg-teal-700 text-white py-20">
        <div className="max-w-3xl mx-auto px-6 text-center">
          <h2 className="text-3xl font-bold mb-4">Ready to Enroll?</h2>
          <p className="text-teal-100 mb-8 max-w-lg mx-auto">
            Fill out our online application form and our team will review your
            submission within 3–5 business days.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/admissions/apply"
              className="bg-white text-teal-700 px-8 py-3 rounded-full font-semibold hover:bg-teal-50 transition-colors"
            >
              Start Application
            </Link>
            <Link
              href="/admissions/review"
              className="border-2 border-white/40 text-white px-8 py-3 rounded-full font-semibold hover:bg-white/10 transition-colors"
            >
              Admin Review
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-zinc-900 text-zinc-400 py-12">
        <div className="max-w-6xl mx-auto px-6 text-center text-sm">
          <p className="mb-2">
            <span className="text-white font-semibold">KinderLog Preschool</span> —
            Nurturing Young Minds Since 2020
          </p>
          <p>
            Ambalangoda · Hikkaduwa | 📞 +94 91 225 6789 | ✉️ info@kinderlog.com
          </p>
          <p className="mt-4 text-zinc-600">
            &copy; {new Date().getFullYear()} KinderLog. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
