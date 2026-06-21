enum BehaviorSeverity { low, moderate, high, critical }
enum BehaviorStatus { open, underReview, resolved, escalated }

/// A confidential behavioral / discipline incident report.
class BehaviorLog {
  final String id;
  final String studentId;
  final String studentName;
  final String classroom;
  final String reportedBy; // Teacher name
  final String reporterId;
  final String title;
  final String description;
  final BehaviorSeverity severity;
  final BehaviorStatus status;
  final DateTime occurredAt;
  final DateTime reportedAt;
  final List<InterventionNote> interventions;
  final bool isSharedWithParent;
  final DateTime? parentViewedAt;

  BehaviorLog({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classroom,
    required this.reportedBy,
    required this.reporterId,
    required this.title,
    required this.description,
    this.severity = BehaviorSeverity.low,
    this.status = BehaviorStatus.open,
    required this.occurredAt,
    DateTime? reportedAt,
    this.interventions = const [],
    this.isSharedWithParent = false,
    this.parentViewedAt,
  }) : reportedAt = reportedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id, 'studentId': studentId, 'studentName': studentName,
        'classroom': classroom, 'reportedBy': reportedBy, 'reporterId': reporterId,
        'title': title, 'description': description,
        'severity': severity.name, 'status': status.name,
        'occurredAt': occurredAt.toIso8601String(),
        'reportedAt': reportedAt.toIso8601String(),
        'isSharedWithParent': isSharedWithParent,
        'parentViewedAt': parentViewedAt?.toIso8601String(),
      };

  factory BehaviorLog.fromJson(Map<String, dynamic> json, String docId) {
    return BehaviorLog(
      id: docId, studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '', classroom: json['classroom'] ?? '',
      reportedBy: json['reportedBy'] ?? '', reporterId: json['reporterId'] ?? '',
      title: json['title'] ?? '', description: json['description'] ?? '',
      severity: _parseSeverity(json['severity']),
      status: _parseStatus(json['status']),
      occurredAt: json['occurredAt'] != null ? DateTime.parse(json['occurredAt']) : DateTime.now(),
      reportedAt: json['reportedAt'] != null ? DateTime.parse(json['reportedAt']) : DateTime.now(),
      isSharedWithParent: json['isSharedWithParent'] ?? false,
      parentViewedAt: json['parentViewedAt'] != null ? DateTime.parse(json['parentViewedAt']) : null,
    );
  }

  static BehaviorSeverity _parseSeverity(String? name) {
    try { return BehaviorSeverity.values.byName(name ?? ''); } catch (_) { return BehaviorSeverity.low; }
  }
  static BehaviorStatus _parseStatus(String? name) {
    try { return BehaviorStatus.values.byName(name ?? ''); } catch (_) { return BehaviorStatus.open; }
  }
}

/// An intervention note added to a behavior log.
class InterventionNote {
  final String id;
  final String behaviorLogId;
  final String authorName;
  final String authorRole; // 'teacher', 'management', 'parent'
  final String note;
  final DateTime createdAt;

  InterventionNote({
    required this.id,
    required this.behaviorLogId,
    required this.authorName,
    this.authorRole = 'teacher',
    required this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id, 'behaviorLogId': behaviorLogId,
        'authorName': authorName, 'authorRole': authorRole,
        'note': note, 'createdAt': createdAt.toIso8601String(),
      };

  factory InterventionNote.fromJson(Map<String, dynamic> json) {
    return InterventionNote(
      id: json['id'] ?? '', behaviorLogId: json['behaviorLogId'] ?? '',
      authorName: json['authorName'] ?? '', authorRole: json['authorRole'] ?? 'teacher',
      note: json['note'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
