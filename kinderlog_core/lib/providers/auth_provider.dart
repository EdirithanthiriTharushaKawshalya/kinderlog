import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/preschool_model.dart';

/// Manages authentication state, preschool setup, branches, classes, and users.
/// Uses in-memory storage (mock) with Firebase-ready structure.
/// Shared by all KinderLog mobile apps.
class AuthProvider extends ChangeNotifier {
  // ---- Core State ----
  AppUser? _currentUser;
  Preschool? _preschool;
  List<Branch> _branches = [];
  List<ClassModel> _classes = [];
  List<AppUser> _users = [];

  bool _isLoading = false;
  String? _errorMessage;

  // ---- Getters ----
  AppUser? get currentUser => _currentUser;
  Preschool? get preschool => _preschool;
  List<Branch> get branches => _branches;
  List<ClassModel> get classes => _classes;
  List<AppUser> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isManagement => _currentUser?.role == UserRole.management;
  bool get isTeacher => _currentUser?.role == UserRole.teacher;
  bool get isFirstLaunch => _preschool == null;

  /// Current user's branch (for teachers) or null (for management).
  Branch? get currentBranch {
    if (_currentUser?.branchId == null || _branches.isEmpty) return null;
    try {
      return _branches.firstWhere((b) => b.id == _currentUser!.branchId);
    } catch (_) {
      return null;
    }
  }

  /// Classes belonging to the current user's branch.
  List<ClassModel> get currentBranchClasses {
    final bid = _currentUser?.branchId;
    if (bid == null) return [];
    return _classes.where((c) => c.branchId == bid).toList();
  }

  /// Pinned class for the current user.
  ClassModel? get pinnedClass {
    if (_currentUser?.pinnedClassId == null) return null;
    try {
      return _classes.firstWhere((c) => c.id == _currentUser!.pinnedClassId);
    } catch (_) {
      return null;
    }
  }

  /// Classes in a given branch.
  List<ClassModel> classesForBranch(String branchId) {
    return _classes.where((c) => c.branchId == branchId).toList();
  }

  /// Branches visible to the current user.
  List<Branch> get accessibleBranches {
    if (isManagement) return _branches;
    final b = currentBranch;
    return b != null ? [b] : [];
  }

  /// Classes visible to the current user (branch-scoped for teachers).
  List<ClassModel> get accessibleClasses {
    if (isManagement) return _classes;
    return currentBranchClasses;
  }

  // ---- Initialization (loads mock data or from storage) ----
  AuthProvider() {
    _initMockData();
  }

  void _initMockData() {
    const pid = 'preschool_01';
    _preschool = Preschool(
      id: pid,
      name: 'DailyKids Preschool',
      ownerEmail: 'admin@dailykids.com',
    );

    final branch1 = Branch(
      id: 'branch_01',
      preschoolId: pid,
      name: 'Ambalangoda',
      location: '123 Galle Road, Ambalangoda',
    );
    final branch2 = Branch(
      id: 'branch_02',
      preschoolId: pid,
      name: 'Hikkaduwa',
      location: '45 Beach Road, Hikkaduwa',
    );
    _branches = [branch1, branch2];

    _classes = [
      ClassModel(id: 'class_01', branchId: 'branch_01', name: 'FS1', teacherId: 'user_teacher_1'),
      ClassModel(id: 'class_02', branchId: 'branch_01', name: 'FS2', teacherId: 'user_teacher_2'),
      ClassModel(id: 'class_03', branchId: 'branch_01', name: 'Yellow', teacherId: null),
      ClassModel(id: 'class_04', branchId: 'branch_01', name: 'Green', teacherId: null),
      ClassModel(id: 'class_05', branchId: 'branch_02', name: 'FS1', teacherId: 'user_teacher_3'),
      ClassModel(id: 'class_06', branchId: 'branch_02', name: 'FS2', teacherId: null),
    ];

    _users = [
      AppUser(
        id: 'user_mgmt_01',
        email: 'admin@dailykids.com',
        name: 'Ms. Priya (Admin)',
        role: UserRole.management,
        preschoolId: pid,
      ),
      AppUser(
        id: 'user_teacher_1',
        email: 'nimali@dailykids.com',
        name: 'Ms. Nimali',
        role: UserRole.teacher,
        preschoolId: pid,
        branchId: 'branch_01',
        pinnedClassId: 'class_01',
      ),
      AppUser(
        id: 'user_teacher_2',
        email: 'sunil@dailykids.com',
        name: 'Mr. Sunil',
        role: UserRole.teacher,
        preschoolId: pid,
        branchId: 'branch_01',
        pinnedClassId: 'class_02',
      ),
      AppUser(
        id: 'user_teacher_3',
        email: 'kumari@dailykids.com',
        name: 'Ms. Kumari',
        role: UserRole.teacher,
        preschoolId: pid,
        branchId: 'branch_02',
        pinnedClassId: 'class_05',
      ),
    ];
  }

  // ---- Management: Preschool Setup ----
  Future<void> createPreschool({
    required String name,
    required String ownerEmail,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final id = 'preschool_${const Uuid().v4().substring(0, 6)}';
      _preschool = Preschool(
        id: id,
        name: name,
        ownerEmail: ownerEmail,
      );

      _currentUser = AppUser(
        id: 'user_mgmt_${const Uuid().v4().substring(0, 6)}',
        email: ownerEmail,
        name: 'Admin',
        role: UserRole.management,
        preschoolId: id,
      );
      _users.add(_currentUser!);
    } catch (e) {
      _errorMessage = 'Failed to create preschool: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Management: Branch CRUD ----
  Future<void> addBranch({required String name, required String location}) async {
    if (_preschool == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final branch = Branch(
        id: 'branch_${const Uuid().v4().substring(0, 6)}',
        preschoolId: _preschool!.id,
        name: name,
        location: location,
      );
      _branches.add(branch);
    } catch (e) {
      _errorMessage = 'Failed to add branch: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeBranch(String branchId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      _branches.removeWhere((b) => b.id == branchId);
      _classes.removeWhere((c) => c.branchId == branchId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Management: Class CRUD ----
  Future<void> addClass({required String branchId, required String name}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final cm = ClassModel(
        id: 'class_${const Uuid().v4().substring(0, 6)}',
        branchId: branchId,
        name: name,
      );
      _classes.add(cm);
    } catch (e) {
      _errorMessage = 'Failed to add class: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeClass(String classId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      _classes.removeWhere((c) => c.id == classId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Management: Add Teacher User ----
  Future<void> addTeacher({
    required String email,
    required String name,
    required String branchId,
    String? classId,
  }) async {
    if (_preschool == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
        _errorMessage = 'A teacher with this email already exists.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final user = AppUser(
        id: 'user_teacher_${const Uuid().v4().substring(0, 6)}',
        email: email,
        name: name,
        role: UserRole.teacher,
        preschoolId: _preschool!.id,
        branchId: branchId,
        pinnedClassId: classId,
      );
      _users.add(user);

      if (classId != null) {
        final idx = _classes.indexWhere((c) => c.id == classId);
        if (idx != -1) {
          _classes[idx] = _classes[idx].copyWith(teacherId: user.id);
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to add teacher: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeTeacher(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      _users.removeWhere((u) => u.id == userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Teacher Login ----
  Future<bool> loginAsTeacher(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.role == UserRole.teacher,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'No teacher found with email: $email. Please ask management to add you.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---- Management Login ----
  Future<bool> loginAsManagement(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.role == UserRole.management,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Invalid management credentials.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---- Pin / Unpin Class ----
  Future<void> pinClass(String classId) async {
    if (_currentUser == null) return;
    try {
      final idx = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(pinnedClassId: classId);
        _currentUser = _users[idx];
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pin class: $e';
      notifyListeners();
    }
  }

  Future<void> unpinClass() async {
    if (_currentUser == null) return;
    try {
      final idx = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(pinnedClassId: null);
        _currentUser = _users[idx];
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to unpin class: $e';
      notifyListeners();
    }
  }

  // ---- Logout ----
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  /// Clear error for UI
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
