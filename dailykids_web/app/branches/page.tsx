"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { db } from "@/lib/firebase";
import { collection, query, orderBy, onSnapshot } from "firebase/firestore";
import type { BranchPublicInfo } from "@/lib/types";

const fallbackBranches: Omit<BranchPublicInfo, "id">[] = [
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
    heroImageUrl: "",
    classNames: ["FS1", "FS2", "Yellow", "Green"],
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
    heroImageUrl: "",
    classNames: ["FS1", "FS2"],
  },
];

export default function BranchesPage() {
  const [branches, setBranches] = useState<BranchPublicInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const q = query(collection(db, "branchInfo"), orderBy("name"));
    const unsub = onSnapshot(q, (snap) => {
      const data = snap.docs.map((d) => ({ id: d.id, ...d.data() } as BranchPublicInfo));
      setBranches(data.length > 0 ? data : fallbackBranches as BranchPublicInfo[]);
      setLoading(false);
      setError(null);
    }, (err) => {
      console.error("Branches listener error:", err);
      setError(err.message);
      setBranches(fallbackBranches as BranchPublicInfo[]);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 max-w-6xl mx-auto px-6 py-16 w-full">
        <h1 className="text-4xl font-bold text-zinc-800 mb-4 text-center">
          Our Branches
        </h1>
        <p className="text-center text-zinc-500 mb-12 max-w-lg mx-auto">
          {branches.length > 0
            ? `${branches.length} convenient ${branches.length === 1 ? "location" : "locations"}, each offering a safe, nurturing environment with certified educators.`
            : "Convenient locations, each offering a safe, nurturing environment with certified educators."}
        </p>

        {error && (
          <div className="mb-8 p-4 bg-amber-50 border border-amber-200 rounded-xl text-sm text-amber-700 max-w-lg mx-auto text-center">
            ⚠️ Could not connect to server. Showing default branch info.
          </div>
        )}

        {loading ? (
          <div className="text-center py-20 text-zinc-400">Loading branches...</div>
        ) : branches.length === 0 ? (
          <div className="text-center py-20 text-zinc-400">
            No branch information available yet.
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {branches.map((b) => (
              <div
                key={b.id ?? b.name}
                className="bg-white rounded-2xl p-8 border border-zinc-200 hover:shadow-lg transition-shadow"
              >
                <h2 className="text-2xl font-bold text-teal-700 mb-3">{b.name}</h2>
                <p className="text-zinc-500 mb-4">{b.description}</p>
                <div className="space-y-2 text-sm text-zinc-600 mb-4">
                  <p>📍 {b.address}</p>
                  <p>📞 {b.phone}</p>
                  <p>✉️ {b.email}</p>
                </div>
                {b.classNames.length > 0 && (
                  <p className="text-sm font-semibold text-zinc-700 mb-2">
                    Classes: {b.classNames.join(", ")}
                  </p>
                )}
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
        )}
      </main>
    </div>
  );
}
