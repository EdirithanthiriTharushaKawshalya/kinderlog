"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { db } from "@/lib/firebase";
import { collection, addDoc } from "firebase/firestore";

const branches = [
  { id: "branch_01", name: "Ambalangoda", classes: ["FS1", "FS2", "Yellow", "Green"] },
  { id: "branch_02", name: "Hikkaduwa", classes: ["FS1", "FS2"] },
];

export default function ApplyPage() {
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState({
    childName: "",
    childDob: "",
    gender: "",
    parentName: "",
    parentPhone: "",
    parentEmail: "",
    preferredBranchId: branches[0].id,
    preferredClass: branches[0].classes[0],
    medicalNotes: "",
    allergies: "",
  });

  const selectedBranch = branches.find((b) => b.id === form.preferredBranchId);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await addDoc(collection(db, "admissions"), {
        childName: form.childName,
        childDob: form.childDob,
        gender: form.gender,
        parentName: form.parentName,
        parentPhone: form.parentPhone,
        parentEmail: form.parentEmail,
        preferredBranchId: form.preferredBranchId,
        preferredBranchName: selectedBranch?.name ?? "",
        preferredClass: form.preferredClass,
        medicalNotes: form.medicalNotes || null,
        allergies: form.allergies || null,
        documents: [],
        status: "pending",
        submittedAt: new Date().toISOString(),
      });
      setSubmitted(true);
    } catch (err) {
      console.error("Submission error:", err);
      alert("Failed to submit. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  if (submitted) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-zinc-50 px-4">
        <div className="bg-white rounded-2xl p-10 max-w-md w-full text-center shadow-lg border border-zinc-200">
          <span className="text-5xl block mb-4">✅</span>
          <h1 className="text-2xl font-bold text-teal-700 mb-2">
            Application Submitted!
          </h1>
          <p className="text-zinc-600 mb-6">
            Thank you! Our team will review your application and contact you
            within 3–5 business days.
          </p>
          <Link
            href="/"
            className="inline-block bg-teal-600 text-white px-6 py-3 rounded-full font-semibold hover:bg-teal-700 transition-colors"
          >
            Back to Home
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 max-w-2xl mx-auto px-6 py-16 w-full">
        <h1 className="text-4xl font-bold text-zinc-800 mb-2">Admissions Application</h1>
        <p className="text-zinc-500 mb-10">
          Fill out the form below to apply for your child. Choose your preferred
          branch and class.
        </p>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Child Info */}
          <div className="bg-white rounded-xl p-6 border border-zinc-200 space-y-4">
            <h2 className="font-bold text-lg text-teal-700">Child Information</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Full Name *
                </label>
                <input
                  type="text"
                  required
                  value={form.childName}
                  onChange={(e) => setForm({ ...form, childName: e.target.value })}
                  className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                  placeholder="Child's full name"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Date of Birth *
                </label>
                <input
                  type="date"
                  required
                  value={form.childDob}
                  onChange={(e) => setForm({ ...form, childDob: e.target.value })}
                  className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-zinc-700 mb-1">
                Gender *
              </label>
              <select
                required
                value={form.gender}
                onChange={(e) => setForm({ ...form, gender: e.target.value })}
                className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
              >
                <option value="">Select...</option>
                <option value="Male">Male</option>
                <option value="Female">Female</option>
              </select>
            </div>
          </div>

          {/* Parent Info */}
          <div className="bg-white rounded-xl p-6 border border-zinc-200 space-y-4">
            <h2 className="font-bold text-lg text-teal-700">Parent / Guardian Information</h2>
            <div>
              <label className="block text-sm font-medium text-zinc-700 mb-1">
                Full Name *
              </label>
              <input
                type="text"
                required
                value={form.parentName}
                onChange={(e) => setForm({ ...form, parentName: e.target.value })}
                className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
              />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Phone *
                </label>
                <input
                  type="tel"
                  required
                  value={form.parentPhone}
                  onChange={(e) => setForm({ ...form, parentPhone: e.target.value })}
                  className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-zinc-700 mb-1">
                  Email
                </label>
                <input
                  type="email"
                  value={form.parentEmail}
                  onChange={(e) => setForm({ ...form, parentEmail: e.target.value })}
                  className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                />
              </div>
            </div>
          </div>

          {/* Branch & Class */}
          <div className="bg-white rounded-xl p-6 border border-zinc-200 space-y-4">
            <h2 className="font-bold text-lg text-teal-700">Preferred Branch & Class</h2>
            <div>
              <label className="block text-sm font-medium text-zinc-700 mb-1">
                Branch *
              </label>
              <select
                required
                value={form.preferredBranchId}
                onChange={(e) => {
                  const branch = branches.find((b) => b.id === e.target.value);
                  setForm({
                    ...form,
                    preferredBranchId: e.target.value,
                    preferredClass: branch?.classes[0] ?? "",
                  });
                }}
                className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
              >
                {branches.map((b) => (
                  <option key={b.id} value={b.id}>
                    {b.name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-zinc-700 mb-1">
                Preferred Class *
              </label>
              <select
                required
                value={form.preferredClass}
                onChange={(e) => setForm({ ...form, preferredClass: e.target.value })}
                className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
              >
                {(selectedBranch?.classes ?? []).map((c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Medical */}
          <div className="bg-white rounded-xl p-6 border border-zinc-200 space-y-4">
            <h2 className="font-bold text-lg text-teal-700">Medical Information</h2>
            <div>
              <label className="block text-sm font-medium text-zinc-700 mb-1">
                Allergies (if any)
              </label>
              <input
                type="text"
                value={form.allergies}
                onChange={(e) => setForm({ ...form, allergies: e.target.value })}
                className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                placeholder="e.g. Peanuts, dairy"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-zinc-700 mb-1">
                Medical Notes
              </label>
              <textarea
                rows={3}
                value={form.medicalNotes}
                onChange={(e) => setForm({ ...form, medicalNotes: e.target.value })}
                className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                placeholder="Any medical conditions or special requirements..."
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-teal-600 text-white py-3.5 rounded-xl font-semibold text-lg hover:bg-teal-700 transition-colors disabled:opacity-50"
          >
            {loading ? "Submitting..." : "Submit Application"}
          </button>
        </form>
      </main>
    </div>
  );
}
