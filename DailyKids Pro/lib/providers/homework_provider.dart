import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/homework_model.dart';

/// Manages homework assignments — teachers create, parents view.
class HomeworkProvider extends ChangeNotifier {
  List<Homework> _homework = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Homework> get homework => _homework;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  HomeworkProvider() {
    _initMockData();
  }

  void _initMockData() {
    final now = DateTime.now();
    _homework = [
      Homework(
        id: 'hw_01',
        teacherId: 'user_teacher_1',
        teacherName: 'Ms. Nimali',
        classId: 'class_01',
        className: 'FS1',
        title: 'Color the Rainbow Worksheet',
        description: 'Please help your child color the rainbow worksheet using crayons. Talk about each color as you go — red, orange, yellow, green, blue, indigo, violet. Return the completed sheet by Friday.',
        dueDate: now.add(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 1)),
        viewedByStudentIds: ['std_1'],
      ),
      Homework(
        id: 'hw_02',
        teacherId: 'user_teacher_1',
        teacherName: 'Ms. Nimali',
        classId: 'class_01',
        className: 'FS1',
        title: 'Counting Practice 1-10',
        description: 'Practice counting from 1 to 10 with your child using household items (spoons, buttons, toys). Write down 3 things you counted together in their notebook.',
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      Homework(
        id: 'hw_03',
        teacherId: 'user_teacher_2',
        teacherName: 'Mr. Sunil',
        classId: 'class_02',
        className: 'FS2',
        title: 'Alphabet Tracing Sheet',
        description: 'Complete the alphabet tracing sheet (A-M). Focus on proper pencil grip. Parents, please sit with your child and guide their hand if needed. Return by Wednesday.',
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 2)),
        viewedByStudentIds: ['std_2'],
      ),
      Homework(
        id: 'hw_04',
        teacherId: 'user_teacher_1',
        teacherName: 'Ms. Nimali',
        classId: 'class_01',
        className: 'FS1',
        title: 'Show & Tell — My Favorite Toy',
        description: 'This Friday is Show & Tell! Help your child choose ONE favorite toy to bring to class. Practice with them: what is it called? Why do they love it? How does it work?',
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }

  /// Homework visible to a teacher (their own assignments).
  List<Homework> homeworkForTeacher(String teacherId) {
    return _homework
        .where((h) => h.teacherId == teacherId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Homework visible to a parent (assignments for their child's class).
  List<Homework> homeworkForStudent(String studentId, String classroom) {
    return _homework
        .where((h) => h.className == classroom)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Teacher creates a new homework assignment.
  Future<void> createHomework({
    required String teacherId,
    required String teacherName,
    required String classId,
    required String className,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final hw = Homework(
        id: 'hw_${const Uuid().v4().substring(0, 6)}',
        teacherId: teacherId,
        teacherName: teacherName,
        classId: classId,
        className: className,
        title: title,
        description: description,
        dueDate: dueDate,
      );
      _homework.insert(0, hw);
    } catch (e) {
      _errorMessage = 'Failed to create homework: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Parent marks a homework as viewed/completed for their child.
  Future<void> markAsViewed(String homeworkId, String studentId) async {
    final idx = _homework.indexWhere((h) => h.id == homeworkId);
    if (idx == -1) return;

    final hw = _homework[idx];
    if (hw.viewedByStudentIds.contains(studentId)) return; // already viewed

    _homework[idx] = hw.copyWith(
      viewedByStudentIds: [...hw.viewedByStudentIds, studentId],
    );
    notifyListeners();
  }

  /// Teacher deletes a homework assignment.
  Future<void> deleteHomework(String homeworkId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      _homework.removeWhere((h) => h.id == homeworkId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get completion count for a homework.
  int viewedCount(String homeworkId, int totalStudents) {
    final hw = _homework.where((h) => h.id == homeworkId).firstOrNull;
    if (hw == null) return 0;
    return hw.viewedByStudentIds.length;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
