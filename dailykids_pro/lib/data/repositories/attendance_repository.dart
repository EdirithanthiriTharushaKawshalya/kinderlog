import 'package:kinderlog_core/kinderlog_core.dart';
import '../models/attendance_record_model.dart';

abstract class AttendanceRepository {
  Future<List<Student>> getStudents();
  Future<void> addStudent(Student student);
  Future<void> updateStudent(Student student);
  Future<List<AttendanceRecord>> getAttendanceForDate(String date);
  Future<void> saveAttendanceRecord(AttendanceRecord record);
  Future<void> deleteAttendanceRecord(String recordId);
}
