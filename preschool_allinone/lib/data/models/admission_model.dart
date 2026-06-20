enum AdmissionStatus { pending, underReview, approved, rejected, waitlisted }

class AdmissionApplication {
  final String id;
  final String childName;
  final DateTime childDob;
  final String gender;
  final String preferredBranchId;
  final String preferredBranchName;
  final String preferredClass;
  final String parentName;
  final String parentPhone;
  final String parentEmail;
  final String address;
  final String? previousSchool;
  final String? medicalNotes;
  final String? allergies;
  final List<UploadedDocument> documents;
  final AdmissionStatus status;
  final String? reviewerNote;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? assignedStudentId; // After approval, linked to Stage 01 roster

  AdmissionApplication({
    required this.id,
    required this.childName,
    required this.childDob,
    required this.gender,
    required this.preferredBranchId,
    required this.preferredBranchName,
    required this.preferredClass,
    required this.parentName,
    required this.parentPhone,
    required this.parentEmail,
    this.address = '',
    this.previousSchool,
    this.medicalNotes,
    this.allergies,
    this.documents = const [],
    this.status = AdmissionStatus.pending,
    this.reviewerNote,
    DateTime? submittedAt,
    this.reviewedAt,
    this.assignedStudentId,
  }) : submittedAt = submittedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'childName': childName,
        'childDob': childDob.toIso8601String(),
        'gender': gender,
        'preferredBranchId': preferredBranchId,
        'preferredBranchName': preferredBranchName,
        'preferredClass': preferredClass,
        'parentName': parentName,
        'parentPhone': parentPhone,
        'parentEmail': parentEmail,
        'address': address,
        'previousSchool': previousSchool,
        'medicalNotes': medicalNotes,
        'allergies': allergies,
        'status': status.name,
        'reviewerNote': reviewerNote,
        'submittedAt': submittedAt.toIso8601String(),
        'reviewedAt': reviewedAt?.toIso8601String(),
        'assignedStudentId': assignedStudentId,
      };

  factory AdmissionApplication.fromJson(Map<String, dynamic> json, String docId) {
    return AdmissionApplication(
      id: docId,
      childName: json['childName'] ?? '',
      childDob: json['childDob'] != null ? DateTime.parse(json['childDob']) : DateTime.now(),
      gender: json['gender'] ?? '',
      preferredBranchId: json['preferredBranchId'] ?? '',
      preferredBranchName: json['preferredBranchName'] ?? '',
      preferredClass: json['preferredClass'] ?? '',
      parentName: json['parentName'] ?? '',
      parentPhone: json['parentPhone'] ?? '',
      parentEmail: json['parentEmail'] ?? '',
      address: json['address'] ?? '',
      previousSchool: json['previousSchool'],
      medicalNotes: json['medicalNotes'],
      allergies: json['allergies'],
      status: _parseStatus(json['status']),
      reviewerNote: json['reviewerNote'],
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : DateTime.now(),
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      assignedStudentId: json['assignedStudentId'],
    );
  }

  static AdmissionStatus _parseStatus(String? s) {
    try {
      return AdmissionStatus.values.byName(s ?? 'pending');
    } catch (_) {
      return AdmissionStatus.pending;
    }
  }
}

class UploadedDocument {
  final String id;
  final String fileName;
  final String fileType; // 'birth_cert', 'medical', 'immunization', 'photo', 'other'
  final String fileUrl; // In real app: storage URL; mock: placeholder
  final DateTime uploadedAt;

  UploadedDocument({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'fileType': fileType,
        'fileUrl': fileUrl,
        'uploadedAt': uploadedAt.toIso8601String(),
      };

  factory UploadedDocument.fromJson(Map<String, dynamic> json) {
    return UploadedDocument(
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'] ?? 'other',
      fileUrl: json['fileUrl'] ?? '',
      uploadedAt: json['uploadedAt'] != null ? DateTime.parse(json['uploadedAt']) : DateTime.now(),
    );
  }
}
