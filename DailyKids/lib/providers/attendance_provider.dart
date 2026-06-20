import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:kinderlog_core/kinderlog_core.dart';

import '../data/models/attendance_record_model.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/repositories/mock_attendance_repository.dart';
import '../data/repositories/firebase_attendance_repository.dart';

/// Comprehensive provider: branch-scoped attendance, analytics engine, parent monitoring.
class AttendanceProvider extends ChangeNotifier {
  final MockAttendanceRepository _mockRepository = MockAttendanceRepository();
  final FirebaseAttendanceRepository _firebaseRepository = FirebaseAttendanceRepository();

  bool _useFirebase = false;
  List<Student> _students = [];
  List<AttendanceRecord> _allRecords = [];
  List<AttendanceRecord> _dailyRecords = [];
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _selectedClassFilter = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Auth context (set externally after login)
  AuthProvider? _auth;
  String _activeBranchId = ''; // For teachers, locked to their branch
  String? _activeClassId; // Pinned or selected class
  bool _isSubstituteMode = false;
  String? _substituteBranchName;

  // ---- Getters ----
  bool get useFirebase => _useFirebase;
  bool get isFirebaseAvailable => FirebaseService.isInitialized;
  List<Student> get students => _students;
  List<AttendanceRecord> get allRecords => _allRecords;
  List<AttendanceRecord> get dailyRecords => _dailyRecords;
  String get selectedDate => _selectedDate;
  String get selectedClassFilter => _selectedClassFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get activeBranchId => _activeBranchId;
  String? get activeClassId => _activeClassId;
  bool get isSubstituteMode => _isSubstituteMode;
  String? get substituteBranchName => _substituteBranchName;

  AttendanceRepository get _activeRepository =>
      (_useFirebase && isFirebaseAvailable) ? _firebaseRepository : _mockRepository;

  /// Initialize provider with auth context (called after login).
  void initialize(AuthProvider auth) {
    _auth = auth;
    if (auth.isTeacher) {
      _activeBranchId = auth.currentUser?.branchId ?? '';
      _activeClassId = auth.currentUser?.pinnedClassId;
    } else {
      // Management sees all
      _activeBranchId = '';
      _activeClassId = null;
    }
    if (_activeClassId != null) {
      final cls = auth.classes.where((c) => c.id == _activeClassId).firstOrNull;
      _selectedClassFilter = cls?.name ?? 'All';
    }
    _loadAll();
  }

  Future<void> _loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _students = await _activeRepository.getStudents();
      // Load all attendance records for analytics (last 12 months)
      _allRecords = await _loadAllAttendanceRecords();
      _dailyRecords = _allRecords.where((r) => r.date == _selectedDate).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<AttendanceRecord>> _loadAllAttendanceRecords() async {
    // Load records for the last 12 months
    final records = <AttendanceRecord>[];
    final now = DateTime.now();
    for (int i = 0; i < 366; i++) {
      final date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      try {
        final dayRecords = await _activeRepository.getAttendanceForDate(date);
        records.addAll(dayRecords);
      } catch (_) {}
    }
    return records;
  }

  // ---- Branch-scoped students ----
  List<Student> get branchStudents {
    if (_activeBranchId.isEmpty) return _students;
    return _students.where((s) => s.branchId == _activeBranchId).toList();
  }

  // ---- Active class filter ----
  List<Student> get filteredStudents {
    var list = _activeBranchId.isEmpty ? _students : branchStudents;

    if (_selectedClassFilter != 'All') {
      list = list.where((s) => s.classroom == _selectedClassFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list.where((s) =>
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.classroom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.parentName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return list;
  }

  // ---- Classroom list for chips ----
  List<String> get availableClassrooms {
    final students = _activeBranchId.isEmpty ? _students : branchStudents;
    final names = students.map((s) => s.classroom).toSet().toList();
    names.sort();
    return ['All', ...names];
  }

  // ---- Setters ----
  Future<void> setUseFirebase(bool value) async {
    if (value && !isFirebaseAvailable) {
      _errorMessage = "Firebase is not initialized!";
      notifyListeners();
      return;
    }
    _useFirebase = value;
    await _loadAll();
  }

  Future<void> setDate(String date) async {
    _selectedDate = date;
    _isLoading = true;
    notifyListeners();
    try {
      _dailyRecords = await _activeRepository.getAttendanceForDate(_selectedDate);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setClassFilter(String classroom) {
    _selectedClassFilter = classroom;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ---- Pin class ----
  Future<void> pinClass(String classId) async {
    _activeClassId = classId;
    if (_auth != null) {
      final cls = _auth!.classes.where((c) => c.id == classId).firstOrNull;
      if (cls != null) {
        _selectedClassFilter = cls.name;
        await _auth!.pinClass(classId);
      }
    }
    notifyListeners();
  }

  Future<void> unpinClass() async {
    _activeClassId = null;
    _selectedClassFilter = 'All';
    if (_auth != null) {
      await _auth!.unpinClass();
    }
    notifyListeners();
  }

  // ---- Substitute teacher mode ----
  void enterSubstituteMode(Branch branch) {
    _isSubstituteMode = true;
    _substituteBranchName = branch.name;
    _activeBranchId = branch.id;
    _selectedClassFilter = 'All';
    notifyListeners();
  }

  void exitSubstituteMode() {
    _isSubstituteMode = false;
    _substituteBranchName = null;
    if (_auth != null && _auth!.isTeacher) {
      _activeBranchId = _auth!.currentUser?.branchId ?? '';
      _activeClassId = _auth!.currentUser?.pinnedClassId;
      if (_activeClassId != null) {
        final cls = _auth!.classes.where((c) => c.id == _activeClassId).firstOrNull;
        _selectedClassFilter = cls?.name ?? 'All';
      } else {
        _selectedClassFilter = 'All';
      }
    }
    notifyListeners();
  }

  // ---- Attendance Record Helpers ----
  AttendanceRecord? getRecordForStudent(String studentId) {
    try {
      return _dailyRecords.firstWhere((rec) => rec.studentId == studentId);
    } catch (_) {
      return null;
    }
  }

  // ---- Mark Attendance ----
  Future<void> markAttendance(
    String studentId,
    AttendanceStatus status, {
    String? note,
    bool doCheckOut = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final existingRecord = getRecordForStudent(studentId);
      final uuid = const Uuid().v1();

      AttendanceRecord record;
      final teacherName = _auth?.currentUser?.name ?? 'Teacher';

      if (existingRecord != null) {
        DateTime? checkIn = existingRecord.checkInTime;
        DateTime? checkOut = existingRecord.checkOutTime;

        if (status == AttendanceStatus.present || status == AttendanceStatus.tardy) {
          checkIn ??= DateTime.now();
        } else {
          checkIn = null;
          checkOut = null;
        }

        if (doCheckOut) {
          checkOut = DateTime.now();
        }

        record = existingRecord.copyWith(
          status: status,
          note: note ?? existingRecord.note,
          checkInTime: checkIn,
          checkOutTime: checkOut,
          markedBy: teacherName,
        );
      } else {
        DateTime? checkIn;
        if (status == AttendanceStatus.present || status == AttendanceStatus.tardy) {
          checkIn = DateTime.now();
        }

        record = AttendanceRecord(
          id: 'rec_${uuid.substring(0, 8)}',
          studentId: studentId,
          date: _selectedDate,
          status: status,
          checkInTime: checkIn,
          checkOutTime: doCheckOut ? DateTime.now() : null,
          markedBy: teacherName,
          note: note,
        );
      }

      await _activeRepository.saveAttendanceRecord(record);
      _dailyRecords = await _activeRepository.getAttendanceForDate(_selectedDate);
      // Also update all records
      _allRecords.removeWhere((r) => r.studentId == studentId && r.date == _selectedDate);
      _allRecords.add(record);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRecordNote(String studentId, String note) async {
    final record = getRecordForStudent(studentId);
    if (record != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final updated = record.copyWith(note: note.isEmpty ? null : note);
        await _activeRepository.saveAttendanceRecord(updated);
        _dailyRecords = await _activeRepository.getAttendanceForDate(_selectedDate);
      } catch (e) {
        _errorMessage = e.toString();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      await markAttendance(studentId, AttendanceStatus.present, note: note);
    }
  }

  // ---- Student CRUD (branch-aware) ----
  Future<void> addNewStudent({
    required String name,
    required String parentName,
    required String parentPhone,
    String? parentEmail,
    required String classroom,
    String? allergies,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = 'std_${const Uuid().v4().substring(0, 8)}';
      final student = Student(
        id: id,
        name: name,
        parentName: parentName,
        parentPhone: parentPhone,
        parentEmail: parentEmail,
        classroom: classroom,
        branchId: _activeBranchId,
        allergies: allergies?.trim().isEmpty ?? true ? 'None' : allergies,
        notes: notes?.trim().isEmpty ?? true ? null : notes,
      );

      await _activeRepository.addStudent(student);
      _students = await _activeRepository.getStudents();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStudentDetails(Student updatedStudent) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _activeRepository.updateStudent(updatedStudent);
      _students = await _activeRepository.getStudents();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeStudent(String studentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Remove attendance records for this student
      final recordsToDelete = _allRecords.where((r) => r.studentId == studentId).toList();
      for (final r in recordsToDelete) {
        await _activeRepository.deleteAttendanceRecord(r.id);
      }
      _allRecords.removeWhere((r) => r.studentId == studentId);
      // Note: repository should also support student deletion
      _students.removeWhere((s) => s.id == studentId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  //  DAILY ATTENDANCE COUNTS (for current filtered view)
  // ============================================================
  int get totalCount => filteredStudents.length;

  int get presentCount => filteredStudents.where((s) {
        final r = getRecordForStudent(s.id);
        return r != null && r.status == AttendanceStatus.present;
      }).length;

  int get absentCount => filteredStudents.where((s) {
        final r = getRecordForStudent(s.id);
        return r != null && r.status == AttendanceStatus.absent;
      }).length;

  int get excusedCount => filteredStudents.where((s) {
        final r = getRecordForStudent(s.id);
        return r != null && r.status == AttendanceStatus.excused;
      }).length;

  int get tardyCount => filteredStudents.where((s) {
        final r = getRecordForStudent(s.id);
        return r != null && r.status == AttendanceStatus.tardy;
      }).length;

  int get uncheckedCount => filteredStudents.where((s) {
        final r = getRecordForStudent(s.id);
        return r == null;
      }).length;

  double get attendancePercentage {
    if (totalCount == 0) return 0.0;
    final markedActive = presentCount + tardyCount;
    return (markedActive / totalCount) * 100;
  }

  // ============================================================
  //  MULTI-TIMEFRAME ANALYTICS ENGINE
  // ============================================================

  /// List of students for analytics (branch-scoped or all)
  List<Student> get _analyticsStudents {
    if (_activeBranchId.isEmpty) return _students;
    return _students.where((s) => s.branchId == _activeBranchId).toList();
  }

  /// Calculate attendance percentage for a student over a date range
  double _attendanceForPeriod(String studentId, DateTime start, DateTime end) {
    final records = _allRecords.where((r) {
      if (r.studentId != studentId) return false;
      try {
        final d = DateTime.parse(r.date);
        return d.isAfter(start.subtract(const Duration(days: 1))) && d.isBefore(end.add(const Duration(days: 1)));
      } catch (_) {
        return false;
      }
    }).toList();

    if (records.isEmpty) return 0.0;

    final presentDays = records.where((r) =>
        r.status == AttendanceStatus.present ||
        r.status == AttendanceStatus.tardy).length;

    return (presentDays / records.length) * 100;
  }

  /// Timeframe enum for analytics queries
  /// Get top N attenders for a period (handles ties)
  List<MapEntry<Student, double>> topAttenders(int n, DateTime start, DateTime end) {
    final results = <MapEntry<Student, double>>[];
    for (final student in _analyticsStudents) {
      final pct = _attendanceForPeriod(student.id, start, end);
      results.add(MapEntry(student, pct));
    }
    results.sort((a, b) => b.value.compareTo(a.value));
    if (results.isEmpty) return [];

    // Include ties: take all entries with the same % as the nth best
    final topN = <MapEntry<Student, double>>[];
    double? lastVal;
    for (final entry in results) {
      if (topN.length < n || entry.value == lastVal) {
        topN.add(entry);
        lastVal = entry.value;
      } else {
        break;
      }
    }
    return topN;
  }

  /// Get low N attenders for a period (handles ties)
  List<MapEntry<Student, double>> lowAttenders(int n, DateTime start, DateTime end) {
    final results = <MapEntry<Student, double>>[];
    for (final student in _analyticsStudents) {
      final pct = _attendanceForPeriod(student.id, start, end);
      results.add(MapEntry(student, pct));
    }
    results.sort((a, b) => a.value.compareTo(b.value));
    if (results.isEmpty) return [];

    // Include ties
    final bottomN = <MapEntry<Student, double>>[];
    double? lastVal;
    for (final entry in results) {
      if (bottomN.length < n || entry.value == lastVal) {
        bottomN.add(entry);
        lastVal = entry.value;
      } else {
        break;
      }
    }
    return bottomN;
  }

  /// Overall attendance % for a period (all students averaged)
  double overallAttendanceForPeriod(DateTime start, DateTime end) {
    if (_analyticsStudents.isEmpty) return 0.0;
    double total = 0;
    for (final student in _analyticsStudents) {
      total += _attendanceForPeriod(student.id, start, end);
    }
    return total / _analyticsStudents.length;
  }

  // ---- Pre-built timeframe helpers ----
  DateTime get _today => DateTime.now();
  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59);

  /// Daily (today)
  Map<String, dynamic> get dailyAnalytics {
    final start = _startOfDay(_today);
    final end = _endOfDay(_today);
    return {
      'label': 'Daily',
      'overall': overallAttendanceForPeriod(start, end),
      'top': topAttenders(5, start, end),
      'low': lowAttenders(5, start, end),
    };
  }

  /// Monthly (last 30 days)
  Map<String, dynamic> get monthlyAnalytics {
    final end = _endOfDay(_today);
    final start = _startOfDay(_today.subtract(const Duration(days: 30)));
    return {
      'label': 'Monthly',
      'overall': overallAttendanceForPeriod(start, end),
      'top': topAttenders(5, start, end),
      'low': lowAttenders(5, start, end),
    };
  }

  /// 6-Month (last 180 days)
  Map<String, dynamic> get sixMonthAnalytics {
    final end = _endOfDay(_today);
    final start = _startOfDay(_today.subtract(const Duration(days: 180)));
    return {
      'label': '6-Month',
      'overall': overallAttendanceForPeriod(start, end),
      'top': topAttenders(5, start, end),
      'low': lowAttenders(5, start, end),
    };
  }

  /// Yearly (last 365 days)
  Map<String, dynamic> get yearlyAnalytics {
    final end = _endOfDay(_today);
    final start = _startOfDay(_today.subtract(const Duration(days: 365)));
    return {
      'label': 'Yearly',
      'overall': overallAttendanceForPeriod(start, end),
      'top': topAttenders(5, start, end),
      'low': lowAttenders(5, start, end),
    };
  }

  /// Get all timeframe analytics
  List<Map<String, dynamic>> get allTimeframeAnalytics => [
        dailyAnalytics,
        monthlyAnalytics,
        sixMonthAnalytics,
        yearlyAnalytics,
      ];

  // ============================================================
  //  PARENT ABSENCE MONITORING
  // ============================================================

  /// Students below a threshold (default 75%) — candidates for parent communication
  List<MapEntry<Student, double>> getLowAttendanceAlerts({
    double threshold = 75.0,
    int periodDays = 30,
  }) {
    final end = _endOfDay(_today);
    final start = _startOfDay(_today.subtract(Duration(days: periodDays)));
    final results = <MapEntry<Student, double>>[];

    for (final student in _analyticsStudents) {
      final pct = _attendanceForPeriod(student.id, start, end);
      if (pct < threshold) {
        results.add(MapEntry(student, pct));
      }
    }
    results.sort((a, b) => a.value.compareTo(b.value)); // lowest first
    return results;
  }

  /// Count of consecutive absences for a student (unexcused)
  int consecutiveAbsences(String studentId) {
    int count = 0;
    final now = _today;
    for (int i = 0; i < 30; i++) {
      final date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final record = _allRecords.where((r) => r.studentId == studentId && r.date == date).firstOrNull;
      if (record != null && record.status == AttendanceStatus.absent) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Generate a parent communication message for a low-attending student
  String generateParentMessage(Student student, double attendancePct, {int? consecutiveAbsences}) {
    final absences = consecutiveAbsences ?? this.consecutiveAbsences(student.id);
    final pctStr = attendancePct.toStringAsFixed(1);

    String message = 'Dear ${student.parentName},\n\n'
        'This is KinderLog Preschool regarding ${student.name}. '
        'Their attendance rate over the last 30 days is $pctStr%.';

    if (absences >= 3) {
      message += '\n\nWe\'ve noticed $absences consecutive unexcused absences. '
          'We\'re concerned and would like to understand if everything is alright.';
    }

    message += '\n\nPlease contact us to discuss any challenges or concerns. '
        'Regular attendance is important for ${student.name}\'s development.\n\n'
        'Kind regards,\nKinderLog Preschool';

    return message;
  }

  /// All students with parent contact info for communication
  List<Map<String, String?>> get parentContactList {
    return _analyticsStudents.map((s) => {
          'studentName': s.name,
          'parentName': s.parentName,
          'parentPhone': s.parentPhone,
          'parentEmail': s.parentEmail,
        }).toList();
  }

  /// School-wide analytics (all branches, management view only)
  Map<String, dynamic> get schoolWideAnalytics {
    final allStudents = _students;
    if (allStudents.isEmpty) {
      return {'overall': 0.0, 'top': <MapEntry<Student, double>>[], 'low': <MapEntry<Student, double>>[]};
    }

    final end = _endOfDay(_today);
    final start = _startOfDay(_today.subtract(const Duration(days: 30)));

    final results = <MapEntry<Student, double>>[];
    for (final student in allStudents) {
      final pct = _attendanceForPeriod(student.id, start, end);
      results.add(MapEntry(student, pct));
    }

    double total = results.fold(0.0, (sum, e) => sum + e.value);
    final overall = results.isEmpty ? 0.0 : total / results.length;

    results.sort((a, b) => b.value.compareTo(a.value));
    final top = results.take(5).toList();

    results.sort((a, b) => a.value.compareTo(b.value));
    final low = results.take(5).toList();

    return {'overall': overall, 'top': top, 'low': low};
  }

  // ---- Cleanup ----
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
