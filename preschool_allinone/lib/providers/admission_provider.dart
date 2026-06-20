import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/admission_model.dart';

/// Manages admission applications, review pipeline, and auto-assignment to roster.
class AdmissionProvider extends ChangeNotifier {
  List<AdmissionApplication> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AdmissionApplication> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<AdmissionApplication> get pendingApplications =>
      _applications.where((a) => a.status == AdmissionStatus.pending).toList();

  List<AdmissionApplication> get underReviewApplications =>
      _applications.where((a) => a.status == AdmissionStatus.underReview).toList();

  List<AdmissionApplication> get approvedApplications =>
      _applications.where((a) => a.status == AdmissionStatus.approved).toList();

  List<AdmissionApplication> get rejectedApplications =>
      _applications.where((a) => a.status == AdmissionStatus.rejected).toList();

  AdmissionProvider() {
    _initMockData();
  }

  void _initMockData() {
    _applications = [
      AdmissionApplication(
        id: 'app_01',
        childName: 'Kavisha Rathnayake',
        childDob: DateTime(2021, 3, 15),
        gender: 'Female',
        preferredBranchId: 'branch_01',
        preferredBranchName: 'Ambalangoda',
        preferredClass: 'FS2',
        parentName: 'Dinesh Rathnayake',
        parentPhone: '+94 77 888 9999',
        parentEmail: 'dinesh.r@email.com',
        address: '56 Temple Road, Ambalangoda',
        medicalNotes: 'Mild asthma — carries inhaler',
        allergies: 'Dust mites',
        status: AdmissionStatus.pending,
        submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      AdmissionApplication(
        id: 'app_02',
        childName: 'Sahan Wickramasinghe',
        childDob: DateTime(2022, 7, 8),
        gender: 'Male',
        preferredBranchId: 'branch_01',
        preferredBranchName: 'Ambalangoda',
        preferredClass: 'Yellow',
        parentName: 'Chamari Wickramasinghe',
        parentPhone: '+94 71 333 2222',
        parentEmail: 'chamari.w@email.com',
        address: '12 Lake Road, Ambalangoda',
        status: AdmissionStatus.underReview,
        submittedAt: DateTime.now().subtract(const Duration(days: 5)),
        reviewedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AdmissionApplication(
        id: 'app_03',
        childName: 'Nethmi Jayasuriya',
        childDob: DateTime(2021, 11, 20),
        gender: 'Female',
        preferredBranchId: 'branch_02',
        preferredBranchName: 'Hikkaduwa',
        preferredClass: 'FS1',
        parentName: 'Ruwan Jayasuriya',
        parentPhone: '+94 76 555 7777',
        parentEmail: 'ruwan.j@email.com',
        address: '78 Beach Road, Hikkaduwa',
        previousSchool: 'Little Stars Daycare',
        status: AdmissionStatus.approved,
        submittedAt: DateTime.now().subtract(const Duration(days: 10)),
        reviewedAt: DateTime.now().subtract(const Duration(days: 7)),
        reviewerNote: 'Approved — welcome to KinderLog!',
        assignedStudentId: 'std_13',
      ),
    ];
  }

  /// Submit a new application (from public website).
  Future<void> submitApplication({
    required String childName,
    required DateTime childDob,
    required String gender,
    required String preferredBranchId,
    required String preferredBranchName,
    required String preferredClass,
    required String parentName,
    required String parentPhone,
    required String parentEmail,
    String address = '',
    String? previousSchool,
    String? medicalNotes,
    String? allergies,
    List<UploadedDocument> documents = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final app = AdmissionApplication(
        id: 'app_${const Uuid().v4().substring(0, 6)}',
        childName: childName,
        childDob: childDob,
        gender: gender,
        preferredBranchId: preferredBranchId,
        preferredBranchName: preferredBranchName,
        preferredClass: preferredClass,
        parentName: parentName,
        parentPhone: parentPhone,
        parentEmail: parentEmail,
        address: address,
        previousSchool: previousSchool,
        medicalNotes: medicalNotes,
        allergies: allergies,
        documents: documents,
      );
      _applications.add(app);
    } catch (e) {
      _errorMessage = 'Failed to submit application: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload a document to an application (mock).
  void uploadDocument(String applicationId, UploadedDocument doc) {
    final idx = _applications.indexWhere((a) => a.id == applicationId);
    if (idx != -1) {
      final app = _applications[idx];
      final docs = List<UploadedDocument>.from(app.documents)..add(doc);
      _applications[idx] = AdmissionApplication(
        id: app.id, childName: app.childName, childDob: app.childDob,
        gender: app.gender, preferredBranchId: app.preferredBranchId,
        preferredBranchName: app.preferredBranchName,
        preferredClass: app.preferredClass, parentName: app.parentName,
        parentPhone: app.parentPhone, parentEmail: app.parentEmail,
        address: app.address, previousSchool: app.previousSchool,
        medicalNotes: app.medicalNotes, allergies: app.allergies,
        documents: docs, status: app.status, reviewerNote: app.reviewerNote,
        submittedAt: app.submittedAt, reviewedAt: app.reviewedAt,
        assignedStudentId: app.assignedStudentId,
      );
      notifyListeners();
    }
  }

  /// Management: update application status.
  Future<void> updateStatus(String applicationId, AdmissionStatus status, {String? note}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final idx = _applications.indexWhere((a) => a.id == applicationId);
      if (idx != -1) {
        final app = _applications[idx];
        _applications[idx] = AdmissionApplication(
          id: app.id, childName: app.childName, childDob: app.childDob,
          gender: app.gender, preferredBranchId: app.preferredBranchId,
          preferredBranchName: app.preferredBranchName,
          preferredClass: app.preferredClass, parentName: app.parentName,
          parentPhone: app.parentPhone, parentEmail: app.parentEmail,
          address: app.address, previousSchool: app.previousSchool,
          medicalNotes: app.medicalNotes, allergies: app.allergies,
          documents: app.documents, status: status,
          reviewerNote: note ?? app.reviewerNote,
          submittedAt: app.submittedAt, reviewedAt: DateTime.now(),
          assignedStudentId: status == AdmissionStatus.approved
              ? 'std_${const Uuid().v4().substring(0, 6)}'
              : app.assignedStudentId,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
