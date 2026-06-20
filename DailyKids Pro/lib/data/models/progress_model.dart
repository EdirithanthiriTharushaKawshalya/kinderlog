enum MilestoneCategory { social, creative, cognitive, physical, language, emotional }
enum MilestoneLevel { emerging, developing, proficient, advanced }

/// A developmental milestone logged by a teacher.
class StudentMilestone {
  final String id;
  final String studentId;
  final String studentName;
  final String classroom;
  final String teacherName;
  final String teacherId;
  final String description;
  final MilestoneCategory category;
  final MilestoneLevel level;
  final DateTime loggedAt;
  final String? evidence; // Optional note about what was observed
  final bool isSharedWithParent;

  StudentMilestone({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classroom,
    required this.teacherName,
    required this.teacherId,
    required this.description,
    required this.category,
    this.level = MilestoneLevel.developing,
    DateTime? loggedAt,
    this.evidence,
    this.isSharedWithParent = false,
  }) : loggedAt = loggedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id, 'studentId': studentId, 'studentName': studentName,
        'classroom': classroom, 'teacherName': teacherName, 'teacherId': teacherId,
        'description': description, 'category': category.name, 'level': level.name,
        'loggedAt': loggedAt.toIso8601String(), 'evidence': evidence,
        'isSharedWithParent': isSharedWithParent,
      };

  factory StudentMilestone.fromJson(Map<String, dynamic> json, String docId) {
    return StudentMilestone(
      id: docId, studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '', classroom: json['classroom'] ?? '',
      teacherName: json['teacherName'] ?? '', teacherId: json['teacherId'] ?? '',
      description: json['description'] ?? '',
      category: _parseCategory(json['category']),
      level: _parseLevel(json['level']),
      loggedAt: json['loggedAt'] != null ? DateTime.parse(json['loggedAt']) : DateTime.now(),
      evidence: json['evidence'], isSharedWithParent: json['isSharedWithParent'] ?? false,
    );
  }

  static MilestoneCategory _parseCategory(String? name) {
    try { return MilestoneCategory.values.byName(name ?? ''); } catch (_) { return MilestoneCategory.social; }
  }
  static MilestoneLevel _parseLevel(String? name) {
    try { return MilestoneLevel.values.byName(name ?? ''); } catch (_) { return MilestoneLevel.developing; }
  }
}

/// A student achievement / recognition announcement.
class StudentAchievement {
  final String id;
  final String studentId;
  final String studentName;
  final String classroom;
  final String title;
  final String description;
  final String awardedBy;
  final DateTime awardedAt;
  final bool isPublic; // Shown in class/school spotlight

  StudentAchievement({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classroom,
    required this.title,
    required this.description,
    required this.awardedBy,
    DateTime? awardedAt,
    this.isPublic = true,
  }) : awardedAt = awardedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id, 'studentId': studentId, 'studentName': studentName,
        'classroom': classroom, 'title': title, 'description': description,
        'awardedBy': awardedBy, 'awardedAt': awardedAt.toIso8601String(),
        'isPublic': isPublic,
      };

  factory StudentAchievement.fromJson(Map<String, dynamic> json, String docId) {
    return StudentAchievement(
      id: docId, studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '', classroom: json['classroom'] ?? '',
      title: json['title'] ?? '', description: json['description'] ?? '',
      awardedBy: json['awardedBy'] ?? '', isPublic: json['isPublic'] ?? true,
      awardedAt: json['awardedAt'] != null ? DateTime.parse(json['awardedAt']) : DateTime.now(),
    );
  }
}
