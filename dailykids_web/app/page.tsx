import Link from "next/link";
import Image from "next/image";

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
      "DailyKids has been a wonderful experience for our daughter. The teachers are caring and communicative.",
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
    email: "ambalangoda@dailykids.com",
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
    email: "hikkaduwa@dailykids.com",
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

export default function Home() {
  return (
    <div className="flex flex-col">

      {/* Hero */}
      <section className="bg-gradient-to-br from-teal-600 to-teal-800 text-white">
        <div className="max-w-6xl mx-auto px-6 py-24 text-center">
          <Image src="/DailyKids.png" alt="DailyKids" width={96} height={96} className="h-24 w-auto mx-auto mb-6" />
          <h1 className="text-5xl font-bold mb-4 tracking-tight">
            DailyKids Preschool
          </h1>
          <p className="text-xl text-white/90 mb-2">Nurturing Young Minds Since 2020</p>
          <p className="text-white/80 max-w-xl mx-auto mb-10">
            Every child is unique. Our play-based curriculum fosters curiosity,
            creativity, and confidence in a safe, nurturing environment.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Link
              href="/admissions/apply"
              className="w-full sm:w-auto text-center bg-white text-teal-700 px-8 py-3 rounded-full font-semibold hover:bg-teal-50 transition-colors"
            >
              Start Application
            </Link>
            <Link
              href="/branches"
              className="w-full sm:w-auto text-center border-2 border-white/40 text-white px-8 py-3 rounded-full font-semibold hover:bg-white/10 transition-colors"
            >
              Our Branches
            </Link>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="max-w-6xl mx-auto px-6 py-20">
        <h2 className="text-3xl font-bold text-center mb-12 text-zinc-800">
          Why Choose DailyKids?
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

      {/* Facebook / Social */}
      <section className="bg-white py-20">
        <div className="max-w-2xl mx-auto px-6 text-center">
          <h2 className="text-3xl font-bold mb-4 text-zinc-800">
            Follow Us on Facebook
          </h2>
          <p className="text-zinc-500 mb-8">
            Stay connected with DailyKids! Follow our Facebook page for
            updates, events, and glimpses into daily life at our preschool.
          </p>
          <a
            href="https://facebook.com/DailyKidsPreschool"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-3 bg-[#1877F2] text-white px-8 py-4 rounded-full font-semibold text-lg hover:bg-[#166fe5] transition-colors shadow-lg shadow-blue-200"
          >
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
              <path d="M22 12c0-5.523-4.477-10-10-10S2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.878v-6.987h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.988C18.343 21.128 22 16.991 22 12z" />
            </svg>
            Visit Our Facebook Page
          </a>
        </div>
      </section>

      {/* Admissions CTA */}
      <section className="bg-teal-700 text-white py-20">
        <div className="max-w-3xl mx-auto px-6 text-center">
          <h2 className="text-3xl font-bold mb-4">Ready to Enroll?</h2>
          <p className="text-white/80 mb-8 max-w-lg mx-auto">
            Fill out our online application form and our team will review your
            submission within 3–5 business days.
          </p>
          <div className="flex justify-center">
            <Link
              href="/admissions/apply"
              className="bg-white text-teal-700 px-8 py-3 rounded-full font-semibold hover:bg-teal-50 transition-colors"
            >
              Start Application
            </Link>
          </div>
        </div>
      </section>


    </div>
  );
}
