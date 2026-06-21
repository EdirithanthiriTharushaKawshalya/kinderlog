"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { db } from "@/lib/firebase";
import {
  collection,
  query,
  orderBy,
  onSnapshot,
  doc,
  updateDoc,
} from "firebase/firestore";
import type { AdmissionApplication } from "@/lib/types";

export default function ReviewPage() {
  const [applications, setApplications] = useState<AdmissionApplication[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<string>("pending");
  const [noteInput, setNoteInput] = useState<Record<string, string>>({});

  useEffect(() => {
    const q = query(collection(db, "admissions"), orderBy("submittedAt", "desc"));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const apps = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })) as AdmissionApplication[];
      setApplications(apps);
      setLoading(false);
      setError(null);
    }, (err) => {
      console.error("Review listener error:", err);
      setError(err.message);
      setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  const filteredApps = applications.filter((a) => a.status === filter || filter === "all");

  const handleStatusChange = async (id: string, status: string) => {
    try {
      await updateDoc(doc(db, "admissions", id), {
        status,
        reviewerNote: noteInput[id] || null,
        reviewedAt: new Date().toISOString(),
      });
      setNoteInput((prev) => {
        const next = { ...prev };
        delete next[id];
        return next;
      });
    } catch (err) {
      console.error("Update error:", err);
      alert("Failed to update application.");
    }
  };

  const statusColor = (status: string) => {
    switch (status) {
      case "pending":
        return "bg-amber-100 text-amber-800";
      case "underReview":
        return "bg-indigo-100 text-indigo-800";
      case "approved":
        return "bg-green-100 text-green-800";
      case "rejected":
        return "bg-red-100 text-red-800";
      default:
        return "bg-zinc-100 text-zinc-800";
    }
  };

  const filters = ["pending", "underReview", "approved", "rejected"];

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
            <Link href="/admin" className="text-zinc-600 hover:text-teal-700 transition-colors">
              Admin
            </Link>
            <Link
              href="/admissions/review"
              className="text-teal-700 border-b-2 border-teal-600 pb-1"
            >
              Review
            </Link>
          </div>
        </nav>
      </header>

      <main className="flex-1 max-w-4xl mx-auto px-6 py-16 w-full">
        <h1 className="text-4xl font-bold text-zinc-800 mb-2">Admission Review</h1>
        <p className="text-zinc-500 mb-8">
          Review, approve, or reject incoming applications.
        </p>

        {/* Filter tabs */}
        <div className="flex gap-2 mb-8 flex-wrap">
          {filters.map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
                filter === f
                  ? "bg-teal-600 text-white"
                  : "bg-white border border-zinc-300 text-zinc-600 hover:bg-zinc-50"
              }`}
            >
              {f.charAt(0).toUpperCase() + f.slice(1)}
              {f === filter && ` (${filteredApps.length})`}
            </button>
          ))}
        </div>

        {error && (
          <div className="mb-8 p-4 bg-red-50 border border-red-200 rounded-xl text-sm text-red-700">
            ⚠️ Could not load applications: {error}
          </div>
        )}

        {loading ? (
          <div className="text-center py-20 text-zinc-400">Loading applications...</div>
        ) : filteredApps.length === 0 ? (
          <div className="text-center py-20 text-zinc-400">
            No {filter} applications found.
          </div>
        ) : (
          <div className="space-y-4">
            {filteredApps.map((app) => (
              <div
                key={app.id}
                className="bg-white rounded-xl p-6 border border-zinc-200 hover:shadow-md transition-shadow"
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-teal-100 flex items-center justify-center text-teal-700 font-bold text-lg">
                      {(app.childName ?? "?")[0]?.toUpperCase()}
                    </div>
                    <div>
                      <h3 className="font-bold text-zinc-800">{app.childName}</h3>
                      <p className="text-xs text-zinc-500">
                        {app.gender} · DOB: {app.childDob}
                      </p>
                    </div>
                  </div>
                  <span
                    className={`px-3 py-1 rounded-full text-xs font-bold uppercase ${statusColor(app.status)}`}
                  >
                    {app.status === "underReview" ? "Review" : app.status}
                  </span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm text-zinc-600 mb-4">
                  <p>
                    <strong>Branch:</strong> {app.preferredBranchName}
                  </p>
                  <p>
                    <strong>Class:</strong> {app.preferredClass}
                  </p>
                  <p>
                    <strong>Parent:</strong> {app.parentName}
                  </p>
                  <p>
                    <strong>Phone:</strong> {app.parentPhone}
                  </p>
                  <p className="sm:col-span-2">
                    <strong>Email:</strong> {app.parentEmail}
                  </p>
                  {app.allergies && (
                    <p className="sm:col-span-2">
                      <strong>Allergies:</strong> {app.allergies}
                    </p>
                  )}
                  {app.medicalNotes && (
                    <p className="sm:col-span-2">
                      <strong>Medical:</strong> {app.medicalNotes}
                    </p>
                  )}
                </div>

                {app.reviewerNote && (
                  <div className="bg-zinc-50 rounded-lg p-3 mb-4 text-sm italic text-zinc-600">
                    Note: {app.reviewerNote}
                  </div>
                )}

                {(app.status === "pending" || app.status === "underReview") && (
                  <div>
                    <input
                      type="text"
                      placeholder="Reviewer note (optional)..."
                      value={noteInput[app.id] ?? ""}
                      onChange={(e) =>
                        setNoteInput({ ...noteInput, [app.id]: e.target.value })
                      }
                      className="w-full border border-zinc-300 rounded-lg px-3 py-2 text-sm mb-3 focus:outline-none focus:ring-2 focus:ring-teal-500"
                    />
                    <div className="flex gap-2">
                      <button
                        onClick={() => handleStatusChange(app.id, "approved")}
                        className="flex-1 bg-green-600 text-white py-2 rounded-lg text-sm font-semibold hover:bg-green-700 transition-colors"
                      >
                        ✅ Approve
                      </button>
                      {app.status === "pending" && (
                        <button
                          onClick={() => handleStatusChange(app.id, "underReview")}
                          className="flex-1 bg-indigo-600 text-white py-2 rounded-lg text-sm font-semibold hover:bg-indigo-700 transition-colors"
                        >
                          🔍 Review
                        </button>
                      )}
                      <button
                        onClick={() => handleStatusChange(app.id, "rejected")}
                        className="flex-1 bg-red-500 text-white py-2 rounded-lg text-sm font-semibold hover:bg-red-600 transition-colors"
                      >
                        ❌ Reject
                      </button>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
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
