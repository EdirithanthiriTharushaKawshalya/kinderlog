import 'package:intl/intl.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../models/attendance_record_model.dart';
import 'attendance_repository.dart';

class MockAttendanceRepository implements AttendanceRepository {
  final List<Student> _students = [];
  final List<AttendanceRecord> _records = [];

  MockAttendanceRepository() {
    _initMockData();
  }

  void _initMockData() {
    // Students across two branches: Ambalangoda (branch_01) and Hikkaduwa (branch_02)
    _students.addAll([
      // ---- Ambalangoda Branch ----
      Student(
        id: 'std_1',
        name: 'Liam Smith',
        parentName: 'John Smith',
        parentPhone: '+1 (555) 019-2834',
        parentEmail: 'john.smith@email.com',
        classroom: 'FS1',
        branchId: 'branch_01',
        allergies: 'None',
        notes: 'Brings blue backpack. Picked up by dad.',
      ),
      Student(
        id: 'std_2',
        name: 'Emma Johnson',
        parentName: 'Sarah Johnson',
        parentPhone: '+1 (555) 014-9843',
        parentEmail: 'sarah.j@email.com',
        classroom: 'FS1',
        branchId: 'branch_01',
        allergies: 'Peanuts',
        notes: 'Has epinephrine auto-injector in her locker.',
      ),
      Student(
        id: 'std_3',
        name: 'Noah Garcia',
        parentName: 'Maria Garcia',
        parentPhone: '+1 (555) 012-4321',
        parentEmail: 'maria.g@email.com',
        classroom: 'FS2',
        branchId: 'branch_01',
        allergies: 'None',
        notes: 'Always picked up by grandmother (Rosa).',
      ),
      Student(
        id: 'std_4',
        name: 'Olivia Martinez',
        parentName: 'David Martinez',
        parentPhone: '+1 (555) 018-7711',
        parentEmail: 'david.m@email.com',
        classroom: 'Yellow',
        branchId: 'branch_01',
        allergies: 'None',
        notes: 'Enjoys finger painting. Quiet but very creative.',
      ),
      Student(
        id: 'std_5',
        name: 'Sophia Davis',
        parentName: 'Emily Davis',
        parentPhone: '+1 (555) 011-5588',
        parentEmail: 'emily.d@email.com',
        classroom: 'Yellow',
        branchId: 'branch_01',
        allergies: 'Dairy (Lactose)',
        notes: 'Requires soy milk for snack time.',
      ),
      Student(
        id: 'std_6',
        name: 'Lucas Miller',
        parentName: 'James Miller',
        parentPhone: '+1 (555) 013-4499',
        parentEmail: 'james.m@email.com',
        classroom: 'Green',
        branchId: 'branch_01',
        allergies: 'None',
        notes: 'Brings his own water bottle. Hard time sleeping during nap.',
      ),
      Student(
        id: 'std_7',
        name: 'Amaya Perera',
        parentName: 'Nimal Perera',
        parentPhone: '+94 77 123 4567',
        parentEmail: 'nimal.p@email.com',
        classroom: 'FS2',
        branchId: 'branch_01',
        allergies: 'None',
        notes: 'Bilingual (Sinhala/English). Very social.',
      ),
      Student(
        id: 'std_8',
        name: 'Kavindu Silva',
        parentName: 'Sunil Silva',
        parentPhone: '+94 77 987 6543',
        parentEmail: 'sunil.s@email.com',
        classroom: 'Green',
        branchId: 'branch_01',
        allergies: 'Shellfish',
        notes: 'Needs extra attention during outdoor play.',
      ),

      // ---- Hikkaduwa Branch ----
      Student(
        id: 'std_9',
        name: 'Aanya Patel',
        parentName: 'Raj Patel',
        parentPhone: '+1 (555) 022-3344',
        parentEmail: 'raj.p@email.com',
        classroom: 'FS1',
        branchId: 'branch_02',
        allergies: 'None',
        notes: 'New student, still adjusting.',
      ),
      Student(
        id: 'std_10',
        name: 'Ishani Fernando',
        parentName: 'Kamal Fernando',
        parentPhone: '+94 71 555 1111',
        parentEmail: 'kamal.f@email.com',
        classroom: 'FS1',
        branchId: 'branch_02',
        allergies: 'Gluten',
        notes: 'Brings gluten-free snacks.',
      ),
      Student(
        id: 'std_11',
        name: 'Rayan De Silva',
        parentName: 'Priya De Silva',
        parentPhone: '+94 76 222 3333',
        parentEmail: 'priya.d@email.com',
        classroom: 'FS2',
        branchId: 'branch_02',
        allergies: 'None',
        notes: 'Excels at counting and numbers.',
      ),
      Student(
        id: 'std_12',
        name: 'Tharushi Jay',
        parentName: 'Thusitha Jay',
        parentPhone: '+94 75 444 5555',
        classroom: 'FS2',
        branchId: 'branch_02',
        allergies: 'None',
        notes: null,
      ),
    ]);

    // ---- Generate historical records for last 30 days ----
    final today = DateTime.now();
    // Helper: generate random-ish consistent attendance patterns
    for (int dayOffset = 0; dayOffset < 30; dayOffset++) {
      final date = DateFormat('yyyy-MM-dd').format(today.subtract(Duration(days: dayOffset)));

      for (final student in _students) {
        // Skip weekends (Saturday=6, Sunday=7)
        final dow = today.subtract(Duration(days: dayOffset)).weekday;
        if (dow == 6 || dow == 7) continue;

        // Generate attendance based on patterns
        final r = _generateRecord(student, date, today.subtract(Duration(days: dayOffset)));
        if (r != null) {
          _records.add(r);
        }
      }
    }
  }

  AttendanceRecord? _generateRecord(Student student, String dateStr, DateTime date) {
    final id = 'rec_${student.id}_$dateStr';
    final teacherNames = ['Ms. Nimali', 'Mr. Sunil', 'Ms. Kumari'];

    // Different attendance patterns per student for realistic data
    final seed = student.id.hashCode + dateStr.hashCode;
    final rand = ((seed.abs() % 100) / 100.0);

    // Known low-attender: std_3 (Noah Garcia) - absent ~40% of time
    // Known high-attender: std_1 (Liam Smith) - present ~95% of time
    if (student.id == 'std_3') {
      if (rand < 0.40) {
        return AttendanceRecord(
          id: id, studentId: student.id, date: dateStr,
          status: AttendanceStatus.absent,
          markedBy: teacherNames[seed % teacherNames.length],
          note: 'Unexcused absence',
        );
      }
    }

    if (student.id == 'std_1') {
      if (rand > 0.95) {
        return AttendanceRecord(
          id: id, studentId: student.id, date: dateStr,
          status: AttendanceStatus.excused,
          markedBy: teacherNames[seed % teacherNames.length],
          note: 'Doctor appointment',
        );
      }
    }

    // Default: most students are present
    if (rand < 0.82) {
      // Present
      final checkIn = DateTime(date.year, date.month, date.day, 8, (seed % 30) + 5);
      final checkOut = DateTime(date.year, date.month, date.day, 16, (seed % 30));
      return AttendanceRecord(
        id: id, studentId: student.id, date: dateStr,
        status: AttendanceStatus.present,
        checkInTime: checkIn,
        checkOutTime: checkOut,
        markedBy: teacherNames[seed % teacherNames.length],
      );
    } else if (rand < 0.90) {
      // Tardy
      final checkIn = DateTime(date.year, date.month, date.day, 9, (seed % 30));
      return AttendanceRecord(
        id: id, studentId: student.id, date: dateStr,
        status: AttendanceStatus.tardy,
        checkInTime: checkIn,
        markedBy: teacherNames[seed % teacherNames.length],
        note: 'Late arrival',
      );
    } else if (rand < 0.95) {
      // Excused
      return AttendanceRecord(
        id: id, studentId: student.id, date: dateStr,
        status: AttendanceStatus.excused,
        markedBy: teacherNames[seed % teacherNames.length],
        note: rand < 0.93 ? 'Sick' : 'Family event',
      );
    } else {
      // Absent
      return AttendanceRecord(
        id: id, studentId: student.id, date: dateStr,
        status: AttendanceStatus.absent,
        markedBy: teacherNames[seed % teacherNames.length],
        note: 'Unexcused',
      );
    }
  }

  @override
  Future<List<Student>> getStudents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_students);
  }

  @override
  Future<void> addStudent(Student student) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _students.add(student);
  }

  @override
  Future<void> updateStudent(Student student) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
    }
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceForDate(String date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _records.where((rec) => rec.date == date).toList();
  }

  @override
  Future<void> saveAttendanceRecord(AttendanceRecord record) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _records.indexWhere((rec) => rec.studentId == record.studentId && rec.date == record.date);
    if (index != -1) {
      _records[index] = record;
    } else {
      _records.add(record);
    }
  }

  @override
  Future<void> deleteAttendanceRecord(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _records.removeWhere((rec) => rec.id == recordId);
  }
}
