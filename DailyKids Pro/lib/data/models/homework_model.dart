/// Represents a homework assignment sent by a teacher to a class.
class Homework {
  final String id;
  final String teacherId;
  final String teacherName;
  final String classId;
  final String className;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  final List<String> attachmentUrls; // optional photo/file URLs
  final List<String> viewedByStudentIds; // students who marked as viewed/completed

  Homework({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.classId,
    required this.className,
    required this.title,
    required this.description,
    required this.dueDate,
    DateTime? createdAt,
    this.attachmentUrls = const [],
    this.viewedByStudentIds = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue => dueDate.isBefore(DateTime.now());

  bool isViewedBy(String studentId) => viewedByStudentIds.contains(studentId);

  Homework copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    List<String>? attachmentUrls,
    List<String>? viewedByStudentIds,
  }) {
    return Homework(
      id: id,
      teacherId: teacherId,
      teacherName: teacherName,
      classId: classId,
      className: className,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      viewedByStudentIds: viewedByStudentIds ?? this.viewedByStudentIds,
    );
  }
}
