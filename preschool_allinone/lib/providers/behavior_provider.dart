import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/behavior_model.dart';

/// Manages confidential behavioral logs, interventions, and parent sharing.
class BehaviorProvider extends ChangeNotifier {
  List<BehaviorLog> _logs = [];
  bool _isLoading = false;

  List<BehaviorLog> get logs => _logs;
  bool get isLoading => _isLoading;

  /// Logs for a specific student.
  List<BehaviorLog> logsForStudent(String studentId) =>
      _logs.where((l) => l.studentId == studentId).toList()..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));

  /// Open/under review logs (needing attention).
  List<BehaviorLog> get activeLogs =>
      _logs.where((l) => l.status == BehaviorStatus.open || l.status == BehaviorStatus.underReview).toList()
        ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));

  /// Resolved logs.
  List<BehaviorLog> get resolvedLogs =>
      _logs.where((l) => l.status == BehaviorStatus.resolved).toList();

  BehaviorProvider() {
    _initMockData();
  }

  void _initMockData() {
    _logs = [
      BehaviorLog(
        id: 'blog_01', studentId: 'std_6', studentName: 'Lucas Miller',
        classroom: 'Green', reportedBy: 'Ms. Nimali', reporterId: 'user_teacher_1',
        title: 'Difficulty during nap time',
        description: 'Lucas has been consistently restless during nap time, disturbing nearby children. He gets up multiple times and talks loudly.',
        severity: BehaviorSeverity.low, status: BehaviorStatus.open,
        occurredAt: DateTime.now().subtract(const Duration(days: 3)),
        interventions: [
          InterventionNote(
            id: 'int_01', behaviorLogId: 'blog_01',
            authorName: 'Ms. Nimali', authorRole: 'teacher',
            note: 'Moved Lucas\'s mat to a quieter corner. Will monitor for improvement over the next week.',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
        isSharedWithParent: true,
      ),
      BehaviorLog(
        id: 'blog_02', studentId: 'std_3', studentName: 'Noah Garcia',
        classroom: 'FS2', reportedBy: 'Mr. Sunil', reporterId: 'user_teacher_2',
        title: 'Physical altercation during play',
        description: 'Noah pushed another child during outdoor play after a dispute over a toy. No injuries. Both children were separated and spoken to.',
        severity: BehaviorSeverity.moderate, status: BehaviorStatus.underReview,
        occurredAt: DateTime.now().subtract(const Duration(days: 5)),
        interventions: [
          InterventionNote(
            id: 'int_02', behaviorLogId: 'blog_02',
            authorName: 'Mr. Sunil', authorRole: 'teacher',
            note: 'Discussed conflict resolution strategies with Noah. Practiced using words instead of hands. Will reinforce daily.',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          InterventionNote(
            id: 'int_03', behaviorLogId: 'blog_02',
            authorName: 'Ms. Priya (Admin)', authorRole: 'management',
            note: 'Reviewed incident. Suggested additional one-on-one social skills sessions.',
            createdAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
        ],
      ),
    ];
  }

  /// Report a new behavior incident.
  Future<void> reportIncident({
    required String studentId,
    required String studentName,
    required String classroom,
    required String reportedBy,
    required String reporterId,
    required String title,
    required String description,
    BehaviorSeverity severity = BehaviorSeverity.low,
    required DateTime occurredAt,
    bool shareWithParent = false,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _logs.add(BehaviorLog(
        id: 'blog_${const Uuid().v4().substring(0, 6)}',
        studentId: studentId, studentName: studentName, classroom: classroom,
        reportedBy: reportedBy, reporterId: reporterId, title: title,
        description: description, severity: severity, occurredAt: occurredAt,
        isSharedWithParent: shareWithParent,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add an intervention note.
  Future<void> addIntervention({
    required String behaviorLogId,
    required String authorName,
    required String authorRole,
    required String note,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final idx = _logs.indexWhere((l) => l.id == behaviorLogId);
      if (idx != -1) {
        final log = _logs[idx];
        final updatedInterventions = List<InterventionNote>.from(log.interventions)
          ..add(InterventionNote(
            id: 'int_${const Uuid().v4().substring(0, 6)}',
            behaviorLogId: behaviorLogId,
            authorName: authorName, authorRole: authorRole, note: note,
          ));
        _logs[idx] = BehaviorLog(
          id: log.id, studentId: log.studentId, studentName: log.studentName,
          classroom: log.classroom, reportedBy: log.reportedBy, reporterId: log.reporterId,
          title: log.title, description: log.description,
          severity: log.severity, status: BehaviorStatus.underReview,
          occurredAt: log.occurredAt, reportedAt: log.reportedAt,
          interventions: updatedInterventions,
          isSharedWithParent: log.isSharedWithParent, parentViewedAt: log.parentViewedAt,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Share a log with parents.
  Future<void> shareWithParent(String logId) async {
    final idx = _logs.indexWhere((l) => l.id == logId);
    if (idx != -1) {
      final log = _logs[idx];
      _logs[idx] = BehaviorLog(
        id: log.id, studentId: log.studentId, studentName: log.studentName,
        classroom: log.classroom, reportedBy: log.reportedBy, reporterId: log.reporterId,
        title: log.title, description: log.description,
        severity: log.severity, status: log.status,
        occurredAt: log.occurredAt, reportedAt: log.reportedAt,
        interventions: log.interventions,
        isSharedWithParent: true, parentViewedAt: log.parentViewedAt,
      );
      notifyListeners();
    }
  }

  /// Resolve a behavior log.
  Future<void> resolveLog(String logId) async {
    final idx = _logs.indexWhere((l) => l.id == logId);
    if (idx != -1) {
      final log = _logs[idx];
      _logs[idx] = BehaviorLog(
        id: log.id, studentId: log.studentId, studentName: log.studentName,
        classroom: log.classroom, reportedBy: log.reportedBy, reporterId: log.reporterId,
        title: log.title, description: log.description,
        severity: log.severity, status: BehaviorStatus.resolved,
        occurredAt: log.occurredAt, reportedAt: log.reportedAt,
        interventions: log.interventions,
        isSharedWithParent: log.isSharedWithParent, parentViewedAt: log.parentViewedAt,
      );
      notifyListeners();
    }
  }
}
