import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/progress_model.dart';

/// Manages student milestones, progress tracking, and achievements.
class ProgressProvider extends ChangeNotifier {
  List<StudentMilestone> _milestones = [];
  List<StudentAchievement> _achievements = [];
  bool _isLoading = false;

  List<StudentMilestone> get milestones => _milestones;
  List<StudentAchievement> get achievements => _achievements;
  bool get isLoading => _isLoading;

  /// Milestones for a specific student.
  List<StudentMilestone> milestonesForStudent(String studentId) =>
      _milestones.where((m) => m.studentId == studentId).toList()..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

  /// Achievements for a specific student.
  List<StudentAchievement> achievementsForStudent(String studentId) =>
      _achievements.where((a) => a.studentId == studentId).toList()..sort((a, b) => b.awardedAt.compareTo(a.awardedAt));

  /// Public achievements (for spotlights).
  List<StudentAchievement> get publicAchievements =>
      _achievements.where((a) => a.isPublic).toList()..sort((a, b) => b.awardedAt.compareTo(a.awardedAt));

  /// Milestones grouped by category for a student.
  Map<MilestoneCategory, List<StudentMilestone>> milestonesByCategory(String studentId) {
    final map = <MilestoneCategory, List<StudentMilestone>>{};
    for (final m in milestonesForStudent(studentId)) {
      map.putIfAbsent(m.category, () => []).add(m);
    }
    return map;
  }

  ProgressProvider() {
    _initMockData();
  }

  void _initMockData() {
    _milestones = [
      StudentMilestone(
        id: 'ms_01', studentId: 'std_1', studentName: 'Liam Smith',
        classroom: 'FS1', teacherName: 'Ms. Nimali', teacherId: 'user_teacher_1',
        description: 'Liam showed remarkable progress in sharing and turn-taking during group activities.',
        category: MilestoneCategory.social, level: MilestoneLevel.proficient,
        loggedAt: DateTime.now().subtract(const Duration(days: 3)),
        evidence: 'Observed during morning circle time — took turns with the talking stick without prompting.',
        isSharedWithParent: true,
      ),
      StudentMilestone(
        id: 'ms_02', studentId: 'std_1', studentName: 'Liam Smith',
        classroom: 'FS1', teacherName: 'Ms. Nimali', teacherId: 'user_teacher_1',
        description: 'Recognizes and writes all uppercase letters independently.',
        category: MilestoneCategory.cognitive, level: MilestoneLevel.advanced,
        loggedAt: DateTime.now().subtract(const Duration(days: 7)),
        evidence: 'Completed alphabet tracing worksheet without assistance.',
        isSharedWithParent: true,
      ),
      StudentMilestone(
        id: 'ms_03', studentId: 'std_2', studentName: 'Emma Johnson',
        classroom: 'FS1', teacherName: 'Ms. Nimali', teacherId: 'user_teacher_1',
        description: 'Emma painted a detailed family portrait with multiple colors and recognizable figures.',
        category: MilestoneCategory.creative, level: MilestoneLevel.advanced,
        loggedAt: DateTime.now().subtract(const Duration(days: 5)),
        evidence: 'Painting displayed on classroom wall. Used 7+ colors with clear composition.',
        isSharedWithParent: true,
      ),
      StudentMilestone(
        id: 'ms_04', studentId: 'std_3', studentName: 'Noah Garcia',
        classroom: 'FS2', teacherName: 'Mr. Sunil', teacherId: 'user_teacher_2',
        description: 'Noah is beginning to express feelings verbally instead of physically.',
        category: MilestoneCategory.emotional, level: MilestoneLevel.emerging,
        loggedAt: DateTime.now().subtract(const Duration(days: 2)),
        evidence: 'Said "I\'m feeling angry" during a disagreement instead of pushing.',
      ),
      StudentMilestone(
        id: 'ms_05', studentId: 'std_4', studentName: 'Olivia Martinez',
        classroom: 'Yellow', teacherName: 'Ms. Nimali', teacherId: 'user_teacher_1',
        description: 'Olivia can hop on one foot for 10+ seconds and skip with alternating feet.',
        category: MilestoneCategory.physical, level: MilestoneLevel.proficient,
        loggedAt: DateTime.now().subtract(const Duration(days: 10)),
        evidence: 'Observed during outdoor play time.',
        isSharedWithParent: true,
      ),
    ];

    _achievements = [
      StudentAchievement(
        id: 'ach_01', studentId: 'std_1', studentName: 'Liam Smith',
        classroom: 'FS1', title: 'Star of the Week',
        description: 'For outstanding helpfulness and kindness towards classmates.',
        awardedBy: 'Ms. Nimali',
        awardedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      StudentAchievement(
        id: 'ach_02', studentId: 'std_2', studentName: 'Emma Johnson',
        classroom: 'FS1', title: 'Creative Artist Award',
        description: 'Emma\'s painting was selected for the school exhibition.',
        awardedBy: 'Ms. Nimali',
        awardedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      StudentAchievement(
        id: 'ach_03', studentId: 'std_4', studentName: 'Olivia Martinez',
        classroom: 'Yellow', title: 'Perfect Attendance — May',
        description: 'Olivia attended every school day in May.',
        awardedBy: 'Ms. Priya (Admin)',
        awardedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  /// Log a new milestone.
  Future<void> logMilestone({
    required String studentId,
    required String studentName,
    required String classroom,
    required String teacherName,
    required String teacherId,
    required String description,
    required MilestoneCategory category,
    MilestoneLevel level = MilestoneLevel.developing,
    String? evidence,
    bool shareWithParent = false,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _milestones.add(StudentMilestone(
        id: 'ms_${const Uuid().v4().substring(0, 6)}',
        studentId: studentId, studentName: studentName, classroom: classroom,
        teacherName: teacherName, teacherId: teacherId, description: description,
        category: category, level: level, evidence: evidence,
        isSharedWithParent: shareWithParent,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Award an achievement.
  Future<void> awardAchievement({
    required String studentId,
    required String studentName,
    required String classroom,
    required String title,
    required String description,
    required String awardedBy,
    bool isPublic = true,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _achievements.add(StudentAchievement(
        id: 'ach_${const Uuid().v4().substring(0, 6)}',
        studentId: studentId, studentName: studentName, classroom: classroom,
        title: title, description: description, awardedBy: awardedBy,
        isPublic: isPublic,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
