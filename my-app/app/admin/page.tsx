"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { db } from "@/lib/firebase";
import {
  collection,
  query,
  onSnapshot,
  addDoc,
  deleteDoc,
  doc,
} from "firebase/firestore";
import type { Branch, ClassModel, AppUser } from "@/lib/types";

export default function AdminPage() {
  const [branches, setBranches] = useState<Branch[]>([]);
  const [classes, setClasses] = useState<ClassModel[]>([]);
  const [users, setUsers] = useState<AppUser[]>([]);
  const [tab, setTab] = useState<"branches" | "classes" | "teachers">("branches");
  const [showAddBranch, setShowAddBranch] = useState(false);
  const [showAddClass, setShowAddClass] = useState(false);
  const [showAddTeacher, setShowAddTeacher] = useState(false);

  // Form state
  const [branchName, setBranchName] = useState("");
  const [branchLocation, setBranchLocation] = useState("");
  const [className, setClassName] = useState("");
  const [classBranchId, setClassBranchId] = useState("");
  const [teacherName, setTeacherName] = useState("");
  const [teacherEmail, setTeacherEmail] = useState("");
  const [teacherBranchId, setTeacherBranchId] = useState("");

  useEffect(() => {
    const unsubBranches = onSnapshot(query(collection(db, "branches")), (snap) => {
      setBranches(snap.docs.map((d) => ({ id: d.id, ...d.data() } as Branch)));
    });
    const unsubClasses = onSnapshot(query(collection(db, "classes")), (snap) => {
      setClasses(snap.docs.map((d) => ({ id: d.id, ...d.data() } as ClassModel)));
    });
    const unsubUsers = onSnapshot(query(collection(db, "users")), (snap) => {
      setUsers(snap.docs.map((d) => ({ id: d.id, ...d.data() } as AppUser)));
    });
    return () => {
      unsubBranches();
      unsubClasses();
      unsubUsers();
    };
  }, []);

  const addBranch = async () => {
    if (!branchName.trim()) return;
    await addDoc(collection(db, "branches"), {
      name: branchName,
      location: branchLocation,
      preschoolId: "preschool_01",
      createdAt: new Date().toISOString(),
    });
    setBranchName("");
    setBranchLocation("");
    setShowAddBranch(false);
  };

  const addClass = async () => {
    if (!className.trim() || !classBranchId) return;
    await addDoc(collection(db, "classes"), {
      name: className,
      branchId: classBranchId,
      createdAt: new Date().toISOString(),
    });
    setClassName("");
    setClassBranchId("");
    setShowAddClass(false);
  };

  const addTeacher = async () => {
    if (!teacherName.trim() || !teacherEmail.trim() || !teacherBranchId) return;
    await addDoc(collection(db, "users"), {
      name: teacherName,
      email: teacherEmail,
      role: "teacher",
      branchId: teacherBranchId,
      preschoolId: "preschool_01",
      createdAt: new Date().toISOString(),
    });
    setTeacherName("");
    setTeacherEmail("");
    setTeacherBranchId("");
    setShowAddTeacher(false);
  };

  const deleteBranch = async (id: string) => {
    await deleteDoc(doc(db, "branches", id));
  };

  const deleteClass = async (id: string) => {
    await deleteDoc(doc(db, "classes", id));
  };

  const deleteTeacher = async (id: string) => {
    await deleteDoc(doc(db, "users", id));
  };

  const teachers = users.filter((u) => u.role === "teacher");

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
            <Link href="/admissions/review" className="text-zinc-600 hover:text-teal-700 transition-colors">
              Review
            </Link>
            <Link href="/admin" className="text-teal-700 border-b-2 border-teal-600 pb-1">
              Admin
            </Link>
          </div>
        </nav>
      </header>

      <main className="flex-1 max-w-4xl mx-auto px-6 py-16 w-full">
        <h1 className="text-4xl font-bold text-zinc-800 mb-2">Admin Panel</h1>
        <p className="text-zinc-500 mb-8">
          Manage branches, classes, and teacher accounts.
        </p>

        {/* Stats */}
        <div className="grid grid-cols-3 gap-4 mb-10">
          {[
            { label: "Branches", value: branches.length, color: "teal" },
            { label: "Classes", value: classes.length, color: "indigo" },
            { label: "Teachers", value: teachers.length, color: "amber" },
          ].map((s) => (
            <div
              key={s.label}
              className="bg-white rounded-xl p-5 border border-zinc-200 text-center"
            >
              <p className={`text-3xl font-bold text-${s.color}-600`}>{s.value}</p>
              <p className="text-xs text-zinc-500 mt-1">{s.label}</p>
            </div>
          ))}
        </div>

        {/* Tabs */}
        <div className="flex gap-2 mb-8">
          {(["branches", "classes", "teachers"] as const).map((t) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`px-5 py-2 rounded-full text-sm font-medium transition-colors ${
                tab === t
                  ? "bg-teal-600 text-white"
                  : "bg-white border border-zinc-300 text-zinc-600 hover:bg-zinc-50"
              }`}
            >
              {t.charAt(0).toUpperCase() + t.slice(1)}
            </button>
          ))}
        </div>

        {/* Branches Tab */}
        {tab === "branches" && (
          <div>
            <button
              onClick={() => setShowAddBranch(!showAddBranch)}
              className="mb-4 bg-teal-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-teal-700 transition-colors"
            >
              + Add Branch
            </button>
            {showAddBranch && (
              <div className="bg-white rounded-xl p-5 border border-zinc-200 mb-6 space-y-3">
                <input
                  type="text"
                  placeholder="Branch name *"
                  value={branchName}
                  onChange={(e) => setBranchName(e.target.value)}
                  className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                />
                <input
                  type="text"
                  placeholder="Location / Address"
                  value={branchLocation}
                  onChange={(e) => setBranchLocation(e.target.value)}
                  className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                />
                <button
                  onClick={addBranch}
                  className="bg-teal-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-teal-700 transition-colors"
                >
                  Save Branch
                </button>
              </div>
            )}
            <div className="space-y-3">
              {branches.map((b) => (
                <div
                  key={b.id}
                  className="bg-white rounded-xl p-5 border border-zinc-200 flex items-center justify-between"
                >
                  <div>
                    <p className="font-bold text-zinc-800">{b.name}</p>
                    <p className="text-sm text-zinc-500">{b.location}</p>
                  </div>
                  <button
                    onClick={() => deleteBranch(b.id)}
                    className="text-red-500 hover:text-red-700 text-sm font-medium"
                  >
                    Delete
                  </button>
                </div>
              ))}
              {branches.length === 0 && (
                <p className="text-zinc-400 text-center py-8">No branches yet.</p>
              )}
            </div>
          </div>
        )}

        {/* Classes Tab */}
        {tab === "classes" && (
          <div>
            <button
              onClick={() => setShowAddClass(!showAddClass)}
              className="mb-4 bg-teal-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-teal-700 transition-colors"
            >
              + Add Class
            </button>
            {showAddClass && (
              <div className="bg-white rounded-xl p-5 border border-zinc-200 mb-6 space-y-3">
                <select
                  value={classBranchId}
                  onChange={(e) => setClassBranchId(e.target.value)}
                  className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                >
                  <option value="">Select Branch *</option>
                  {branches.map((b) => (
                    <option key={b.id} value={b.id}>
                      {b.name}
                    </option>
                  ))}
                </select>
                <input
                  type="text"
                  placeholder="Class name (e.g. FS1) *"
                  value={className}
                  onChange={(e) => setClassName(e.target.value)}
                  className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                />
                <button
                  onClick={addClass}
                  className="bg-teal-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-teal-700 transition-colors"
                >
                  Save Class
                </button>
              </div>
            )}
            {branches.map((branch) => {
              const branchClasses = classes.filter((c) => c.branchId === branch.id);
              if (branchClasses.length === 0) return null;
              return (
                <div key={branch.id} className="mb-6">
                  <h3 className="text-sm font-bold text-teal-700 mb-2">
                    {branch.name}
                  </h3>
                  <div className="space-y-2">
                    {branchClasses.map((c) => {
                      const teacher = teachers.find((t) => t.id === c.teacherId);
                      return (
                        <div
                          key={c.id}
                          className="bg-white rounded-lg p-4 border border-zinc-200 flex items-center justify-between"
                        >
                          <div>
                            <p className="font-semibold text-zinc-800">{c.name}</p>
                            <p className="text-xs text-zinc-500">
                              Teacher: {teacher?.name ?? "Unassigned"}
                            </p>
                          </div>
                          <button
                            onClick={() => deleteClass(c.id)}
                            className="text-red-500 hover:text-red-700 text-sm"
                          >
                            Delete
                          </button>
                        </div>
                      );
                    })}
                  </div>
                </div>
              );
            })}
            {classes.length === 0 && (
              <p className="text-zinc-400 text-center py-8">No classes yet.</p>
            )}
          </div>
        )}

        {/* Teachers Tab */}
        {tab === "teachers" && (
          <div>
            <button
              onClick={() => setShowAddTeacher(!showAddTeacher)}
              className="mb-4 bg-teal-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-teal-700 transition-colors"
            >
              + Add Teacher
            </button>
            {showAddTeacher && (
              <div className="bg-white rounded-xl p-5 border border-zinc-200 mb-6 space-y-3">
                <input
                  type="text"
                  placeholder="Full name *"
                  value={teacherName}
                  onChange={(e) => setTeacherName(e.target.value)}
                  className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                />
                <input
                  type="email"
                  placeholder="Email (for login) *"
                  value={teacherEmail}
                  onChange={(e) => setTeacherEmail(e.target.value)}
                  className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                />
                <select
                  value={teacherBranchId}
                  onChange={(e) => setTeacherBranchId(e.target.value)}
                  className="w-full border border-zinc-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                >
                  <option value="">Select Branch *</option>
                  {branches.map((b) => (
                    <option key={b.id} value={b.id}>
                      {b.name}
                    </option>
                  ))}
                </select>
                <button
                  onClick={addTeacher}
                  className="bg-teal-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-teal-700 transition-colors"
                >
                  Save Teacher
                </button>
              </div>
            )}
            <div className="space-y-3">
              {teachers.map((t) => {
                const branchName =
                  branches.find((b) => b.id === t.branchId)?.name ?? "No branch";
                return (
                  <div
                    key={t.id}
                    className="bg-white rounded-xl p-5 border border-zinc-200 flex items-center justify-between"
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-teal-100 flex items-center justify-center text-teal-700 font-bold">
                        {t.name?.[0]?.toUpperCase() ?? "?"}
                      </div>
                      <div>
                        <p className="font-bold text-zinc-800">{t.name}</p>
                        <p className="text-xs text-zinc-500">{t.email}</p>
                        <p className="text-xs text-zinc-400">{branchName}</p>
                      </div>
                    </div>
                    <button
                      onClick={() => deleteTeacher(t.id)}
                      className="text-red-500 hover:text-red-700 text-sm font-medium"
                    >
                      Delete
                    </button>
                  </div>
                );
              })}
              {teachers.length === 0 && (
                <p className="text-zinc-400 text-center py-8">No teachers yet.</p>
              )}
            </div>
          </div>
        )}
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
