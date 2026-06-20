import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../models/attendance_record_model.dart';
import 'attendance_repository.dart';

class FirebaseAttendanceRepository implements AttendanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _studentsCollection =>
      _firestore.collection('students');

  CollectionReference<Map<String, dynamic>> get _attendanceCollection =>
      _firestore.collection('attendance');

  @override
  Future<List<Student>> getStudents() async {
    try {
      final snapshot = await _studentsCollection.get();
      return snapshot.docs.map((doc) => Student.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to load students from Firestore: $e');
    }
  }

  @override
  Future<void> addStudent(Student student) async {
    try {
      await _studentsCollection.doc(student.id).set(student.toJson());
    } catch (e) {
      throw Exception('Failed to add student to Firestore: $e');
    }
  }

  @override
  Future<void> updateStudent(Student student) async {
    try {
      await _studentsCollection.doc(student.id).update(student.toJson());
    } catch (e) {
      throw Exception('Failed to update student in Firestore: $e');
    }
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceForDate(String date) async {
    try {
      final snapshot = await _attendanceCollection.where('date', isEqualTo: date).get();
      return snapshot.docs
          .map((doc) => AttendanceRecord.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to load attendance from Firestore: $e');
    }
  }

  @override
  Future<void> saveAttendanceRecord(AttendanceRecord record) async {
    try {
      await _attendanceCollection.doc(record.id).set(record.toJson());
    } catch (e) {
      throw Exception('Failed to save attendance record to Firestore: $e');
    }
  }

  @override
  Future<void> deleteAttendanceRecord(String recordId) async {
    try {
      await _attendanceCollection.doc(recordId).delete();
    } catch (e) {
      throw Exception('Failed to delete attendance record from Firestore: $e');
    }
  }
}
