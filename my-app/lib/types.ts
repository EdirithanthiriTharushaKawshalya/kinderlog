// ---- Core Types (mirrors kinderlog_core Dart models) ----

export interface Preschool {
  id: string;
  name: string;
  ownerEmail: string;
  logoUrl?: string;
  createdAt: string;
}

export interface Branch {
  id: string;
  preschoolId: string;
  name: string;
  location: string;
  createdAt: string;
}

export interface ClassModel {
  id: string;
  branchId: string;
  name: string;
  teacherId?: string;
  createdAt: string;
}

export type UserRole = "management" | "teacher";

export interface AppUser {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  preschoolId: string;
  branchId?: string;
  pinnedClassId?: string;
  createdAt: string;
}

export interface Student {
  id: string;
  name: string;
  parentName: string;
  parentPhone: string;
  parentEmail?: string;
  classroom: string;
  branchId: string;
  photoUrl?: string;
  allergies?: string;
  notes?: string;
}

// ---- Website Types ----

export interface BranchPublicInfo {
  branchId: string;
  name: string;
  address: string;
  phone: string;
  email: string;
  description: string;
  facilities: string[];
  heroImageUrl: string;
  classNames: string[];
}

export interface GalleryItem {
  id: string;
  imageUrl: string;
  caption: string;
  category: "facilities" | "events" | "classroom" | "safety";
  uploadedAt: string;
}

export interface Testimonial {
  id: string;
  parentName: string;
  childName: string;
  quote: string;
  rating: number;
  date: string;
}

// ---- Admission Types ----

export type AdmissionStatus = "pending" | "underReview" | "approved" | "rejected";

export interface DocumentUpload {
  fileName: string;
  fileUrl: string;
  uploadedAt: string;
}

export interface AdmissionApplication {
  id: string;
  childName: string;
  childDob: string;
  gender: string;
  parentName: string;
  parentPhone: string;
  parentEmail: string;
  preferredBranchId: string;
  preferredBranchName: string;
  preferredClass: string;
  medicalNotes?: string;
  allergies?: string;
  documents: DocumentUpload[];
  status: AdmissionStatus;
  reviewerNote?: string;
  submittedAt: string;
  reviewedAt?: string;
  reviewedBy?: string;
}

// ---- Payment Types ----

export interface FeeStructure {
  id: string;
  branchId: string;
  name: string;
  amount: number;
  frequency: "monthly" | "termly" | "yearly" | "one-time";
  description: string;
  createdAt: string;
}
