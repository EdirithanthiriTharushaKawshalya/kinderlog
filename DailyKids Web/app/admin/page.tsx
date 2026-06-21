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
  addDoc,
  updateDoc,
  deleteDoc,
  doc,
} from "firebase/firestore";
import type { AdmissionApplication, BranchPublicInfo } from "@/lib/types";

type Tab = "admissions" | "branches";
type StatusFilter = "all" | "pending" | "underReview" | "approved" | "rejected";

export default function AdminPage() {
  const [tab, setTab] = useState<Tab>("admissions");

  // --- Admissions state ---
  const [applications, setApplications] = useState<AdmissionApplication[]>([]);
  const [filter, setFilter] = useState<StatusFilter>("pending");

  // --- Branches state ---
  const [branches, setBranches] = useState<BranchPublicInfo[]>([]);
  const [editingBranch, setEditingBranch] = useState<BranchPublicInfo | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [branchForm, setBranchForm] = useState({
    name: "",
    address: "",
    phone: "",
    email: "",
    description: "",
    facilities: "",
    classes: "",
  });

  // --- Firestore listeners ---
  useEffect(() => {
    const unsubAdmissions = onSnapshot(
      query(collection(db, "admissions"), orderBy("submittedAt", "desc")),
      (snap) => {
        setApplications(
          snap.docs.map((d) => ({ id: d.id, ...d.data() } as AdmissionApplication))
        );
      }
    );

    const unsubBranches = onSnapshot(
      query(collection(db, "branchInfo"), orderBy("name")),
      (snap) => {
        setBranches(
          snap.docs.map((d) => ({ id: d.id, ...d.data() } as unknown as BranchPublicInfo))
        );
      }
    );

    return () => {
      unsubAdmissions();
      unsubBranches();
    };
  }, []);

  // --- Admission helpers ---
  const updateAdmissionStatus = async (id: string, status: string) => {
    await updateDoc(doc(db, "admissions", id), {
      status,
      reviewedAt: new Date().toISOString(),
    });
  };

  const counts = {
    all: applications.length,
    pending: applications.filter((a) => a.status === "pending").length,
    underReview: applications.filter((a) => a.status === "underReview").length,
    approved: applications.filter((a) => a.status === "approved").length,
    rejected: applications.filter((a) => a.status === "rejected").length,
  };

  const filteredApps =
    filter === "all"
      ? applications
      : applications.filter((a) => a.status === filter);

  const statusBadge = (status: string) => {
    const map: Record<string, string> = {
      pending: "bg-amber-100 text-amber-800",
      underReview: "bg-indigo-100 text-indigo-800",
      approved: "bg-green-100 text-green-800",
      rejected: "bg-red-100 text-red-800",
    };
    return map[status] ?? "bg-zinc-100 text-zinc-800";
  };

  // --- Branch helpers ---
  const resetBranchForm = () => {
    setBranchForm({ name: "", address: "", phone: "", email: "", description: "", facilities: "", classes: "" });
    setEditingBranch(null);
    setShowAddForm(false);
  };

  const openEdit = (b: BranchPublicInfo) => {
    setEditingBranch(b);
    setShowAddForm(false);
    setBranchForm({
      name: b.name,
      address: b.address,
      phone: b.phone,
      email: b.email,
      description: b.description,
      facilities: b.facilities.join(", "),
      classes: b.classNames.join(", "),
    });
  };

  const saveBranch = async () => {
    if (!branchForm.name.trim()) return;
    const data = {
      name: branchForm.name.trim(),
      address: branchForm.address.trim(),
      phone: branchForm.phone.trim(),
      email: branchForm.email.trim(),
      description: branchForm.description.trim(),
      facilities: branchForm.facilities
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean),
      classNames: branchForm.classes
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean),
    };

    if (editingBranch) {
      await updateDoc(doc(db, "branchInfo", editingBranch.id!), data);
    } else {
      await addDoc(collection(db, "branchInfo"), {
        ...data,
        heroImageUrl: "",
        createdAt: new Date().toISOString(),
      });
    }
    resetBranchForm();
  };

  const deleteBranch = async (id: string) => {
    if (!confirm("Delete this branch?")) return;
    await deleteDoc(doc(db, "branchInfo", id));
  };

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
            <Link href="/admin" className="text-teal-700 border-b-2 border-teal-600 pb-1">
              Admin
            </Link>
          </div>
        </nav>
      </header>

      <main className="flex-1 max-w-5xl mx-auto px-6 py-16 w-full">
        {/* Tab bar */}
        <div className="flex gap-2 mb-10">
          {([
            { key: "admissions" as const, label: "Admissions" },
            { key: "branches" as const, label: "Branches" },
          ]).map((t) => (
            <button
              key={t.key}
              onClick={() => setTab(t.key)}
              className={`px-6 py-2.5 rounded-full text-sm font-semibold transition-colors ${
                tab === t.key
                  ? "bg-teal-600 text-white shadow-md shadow-teal-200"
                  : "bg-white border border-zinc-300 text-zinc-600 hover:bg-zinc-50"
              }`}
            >
              {t.label}
            </button>
          ))}
        </div>

        {/* ========== ADMISSIONS TAB ========== */}
        {tab === "admissions" && (
          <>
            <div className="flex items-center justify-between mb-2">
              <div>
                <h1 className="text-4xl font-bold text-zinc-800">Admissions</h1>
                <p className="text-zinc-500 mt-1">Review and manage incoming applications</p>
              </div>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-5 gap-3 mb-10">
              {([
                { label: "Total", key: "all" as const, color: "text-zinc-700", bg: "bg-zinc-50" },
                { label: "Pending", key: "pending" as const, color: "text-amber-700", bg: "bg-amber-50" },
                { label: "In Review", key: "underReview" as const, color: "text-indigo-700", bg: "bg-indigo-50" },
                { label: "Approved", key: "approved" as const, color: "text-green-700", bg: "bg-green-50" },
                { label: "Rejected", key: "rejected" as const, color: "text-red-700", bg: "bg-red-50" },
              ]).map((s) => (
                <button
                  key={s.key}
                  onClick={() => setFilter(s.key)}
                  className={`${s.bg} rounded-xl p-4 border text-center transition-all ${
                    filter === s.key ? "border-teal-400 ring-2 ring-teal-200" : "border-zinc-200 hover:border-zinc-300"
                  }`}
                >
                  <p className={`text-2xl font-bold ${s.color}`}>{counts[s.key]}</p>
                  <p className="text-xs text-zinc-500 mt-0.5">{s.label}</p>
                </button>
              ))}
            </div>

            {filteredApps.length === 0 ? (
              <div className="text-center py-16">
                <span className="text-5xl block mb-4">📋</span>
                <p className="text-zinc-400 text-lg">No {filter === "all" ? "" : filter} applications found.</p>
              </div>
            ) : (
              <div className="space-y-4">
                {filteredApps.map((app) => (
                  <div key={app.id} className="bg-white rounded-xl p-6 border border-zinc-200 hover:shadow-md transition-shadow">
                    <div className="flex items-start justify-between mb-4">
                      <div className="flex items-center gap-4">
                        <div className="w-12 h-12 rounded-full bg-teal-100 flex items-center justify-center text-teal-700 font-bold text-lg">
                          {(app.childName ?? "?")[0]?.toUpperCase()}
                        </div>
                        <div>
                          <h3 className="font-bold text-lg text-zinc-800">{app.childName}</h3>
                          <p className="text-sm text-zinc-500">{app.gender} · DOB: {app.childDob}</p>
                        </div>
                      </div>
                      <span className={`px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wide ${statusBadge(app.status)}`}>
                        {app.status === "underReview" ? "In Review" : app.status}
                      </span>
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-x-6 gap-y-2 text-sm text-zinc-600 mb-4">
                      <p><span className="text-zinc-400">Branch</span> <span className="font-medium text-zinc-800">{app.preferredBranchName}</span></p>
                      <p><span className="text-zinc-400">Class</span> <span className="font-medium text-zinc-800">{app.preferredClass}</span></p>
                      <p><span className="text-zinc-400">Parent</span> <span className="font-medium text-zinc-800">{app.parentName}</span></p>
                      <p><span className="text-zinc-400">Phone</span> <span className="font-medium text-zinc-800">{app.parentPhone}</span></p>
                      <p className="sm:col-span-2"><span className="text-zinc-400">Email</span> <span className="font-medium text-zinc-800">{app.parentEmail}</span></p>
                      {app.allergies && <p className="sm:col-span-3"><span className="text-zinc-400">Allergies</span> <span className="font-medium text-red-700">{app.allergies}</span></p>}
                      {app.medicalNotes && <p className="sm:col-span-3"><span className="text-zinc-400">Medical</span> <span className="font-medium text-zinc-800">{app.medicalNotes}</span></p>}
                    </div>

                    <p className="text-xs text-zinc-400 mb-3">
                      Submitted {new Date(app.submittedAt).toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric", hour: "2-digit", minute: "2-digit" })}
                    </p>

                    {app.reviewerNote && (
                      <div className="bg-zinc-50 rounded-lg p-3 mb-4 text-sm italic text-zinc-600 border border-zinc-100">
                        <span className="font-semibold not-italic text-zinc-500">Review note:</span> {app.reviewerNote}
                      </div>
                    )}

                    {(app.status === "pending" || app.status === "underReview") && (
                      <div className="flex gap-3 pt-2 border-t border-zinc-100">
                        <button onClick={() => updateAdmissionStatus(app.id, "approved")} className="flex-1 bg-emerald-600 text-white py-2.5 rounded-lg text-sm font-semibold hover:bg-emerald-700 transition-colors">Approve</button>
                        {app.status === "pending" && (
                          <button onClick={() => updateAdmissionStatus(app.id, "underReview")} className="flex-1 bg-indigo-600 text-white py-2.5 rounded-lg text-sm font-semibold hover:bg-indigo-700 transition-colors">Mark in Review</button>
                        )}
                        <button onClick={() => updateAdmissionStatus(app.id, "rejected")} className="flex-1 bg-red-500 text-white py-2.5 rounded-lg text-sm font-semibold hover:bg-red-600 transition-colors">Reject</button>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </>
        )}

        {/* ========== BRANCHES TAB ========== */}
        {tab === "branches" && (
          <>
            <div className="flex items-center justify-between mb-8">
              <div>
                <h1 className="text-4xl font-bold text-zinc-800">Branches</h1>
                <p className="text-zinc-500 mt-1">Manage branch information shown on the public website</p>
              </div>
              {!showAddForm && !editingBranch && (
                <button
                  onClick={() => setShowAddForm(true)}
                  className="bg-teal-600 text-white px-5 py-2.5 rounded-full text-sm font-semibold hover:bg-teal-700 transition-colors shadow-sm"
                >
                  + Add Branch
                </button>
              )}
            </div>

            {/* Add / Edit form */}
            {(showAddForm || editingBranch) && (
              <div className="bg-white rounded-xl p-6 border border-teal-200 shadow-sm mb-8 space-y-4">
                <h3 className="font-bold text-lg text-teal-700">
                  {editingBranch ? `Edit: ${editingBranch.name}` : "New Branch"}
                </h3>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <input
                    type="text"
                    placeholder="Branch name *"
                    value={branchForm.name}
                    onChange={(e) => setBranchForm({ ...branchForm, name: e.target.value })}
                    className="border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                  />
                  <input
                    type="text"
                    placeholder="Address"
                    value={branchForm.address}
                    onChange={(e) => setBranchForm({ ...branchForm, address: e.target.value })}
                    className="border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                  />
                  <input
                    type="text"
                    placeholder="Phone"
                    value={branchForm.phone}
                    onChange={(e) => setBranchForm({ ...branchForm, phone: e.target.value })}
                    className="border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                  />
                  <input
                    type="email"
                    placeholder="Email"
                    value={branchForm.email}
                    onChange={(e) => setBranchForm({ ...branchForm, email: e.target.value })}
                    className="border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                  />
                  <div className="sm:col-span-2">
                    <textarea
                      rows={3}
                      placeholder="Description"
                      value={branchForm.description}
                      onChange={(e) => setBranchForm({ ...branchForm, description: e.target.value })}
                      className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-zinc-500 mb-1">Facilities (comma-separated)</label>
                    <input
                      type="text"
                      placeholder="e.g. CCTV, Playground, Nap room"
                      value={branchForm.facilities}
                      onChange={(e) => setBranchForm({ ...branchForm, facilities: e.target.value })}
                      className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-zinc-500 mb-1">Classes (comma-separated)</label>
                    <input
                      type="text"
                      placeholder="e.g. FS1, FS2, Yellow"
                      value={branchForm.classes}
                      onChange={(e) => setBranchForm({ ...branchForm, classes: e.target.value })}
                      className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                    />
                  </div>
                </div>
                <div className="flex gap-3 pt-2">
                  <button
                    onClick={saveBranch}
                    className="bg-teal-600 text-white px-6 py-2.5 rounded-lg text-sm font-semibold hover:bg-teal-700 transition-colors"
                  >
                    {editingBranch ? "Update Branch" : "Save Branch"}
                  </button>
                  <button
                    onClick={resetBranchForm}
                    className="bg-white border border-zinc-300 text-zinc-600 px-6 py-2.5 rounded-lg text-sm font-semibold hover:bg-zinc-50 transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            )}

            {/* Branch list */}
            {branches.length === 0 && !showAddForm && !editingBranch ? (
              <div className="text-center py-16">
                <span className="text-5xl block mb-4">🏫</span>
                <p className="text-zinc-400 text-lg mb-2">No branches configured yet.</p>
                <p className="text-zinc-400 text-sm">Click &quot;Add Branch&quot; to create the first one.</p>
              </div>
            ) : (
              <div className="space-y-4">
                {branches.map((b) => (
                  <div key={b.id} className="bg-white rounded-xl p-6 border border-zinc-200 hover:shadow-sm transition-shadow">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h3 className="font-bold text-lg text-zinc-800">{b.name}</h3>
                        <p className="text-sm text-zinc-500 mt-1">{b.description}</p>
                        <div className="grid grid-cols-1 sm:grid-cols-3 gap-x-6 gap-y-1 mt-3 text-sm text-zinc-600">
                          <p>📍 {b.address}</p>
                          <p>📞 {b.phone}</p>
                          <p>✉️ {b.email}</p>
                        </div>
                        <div className="flex flex-wrap gap-2 mt-3">
                          {b.classNames.map((c) => (
                            <span key={c} className="text-xs bg-teal-50 text-teal-700 px-3 py-1 rounded-full font-medium">
                              {c}
                            </span>
                          ))}
                        </div>
                        <div className="flex flex-wrap gap-2 mt-2">
                          {b.facilities.map((f) => (
                            <span key={f} className="text-xs bg-zinc-100 text-zinc-600 px-3 py-1 rounded-full">
                              {f}
                            </span>
                          ))}
                        </div>
                      </div>
                      <div className="flex gap-2 ml-4">
                        <button
                          onClick={() => openEdit(b)}
                          className="text-sm text-teal-600 hover:text-teal-800 font-medium"
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => deleteBranch(b.id!)}
                          className="text-sm text-red-500 hover:text-red-700 font-medium"
                        >
                          Delete
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </>
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
