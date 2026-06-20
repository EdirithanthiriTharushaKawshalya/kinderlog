import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/progress_provider.dart';

import '../../providers/attendance_provider.dart';
import '../../data/models/progress_model.dart';

/// Student progress monitoring: milestones, achievements, and spotlights.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedStudentId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProgressProvider, AttendanceProvider>(
      builder: (context, progress, attendance, _) {
        final students = attendance.branchStudents;

        // If a student is selected, show their detailed view
        if (_selectedStudentId != null) {
          final student = students.where((s) => s.id == _selectedStudentId).firstOrNull;
          if (student != null) return _studentDetailView(context, progress, student);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Progress & Recognition'),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryTeal,
              labelColor: AppTheme.primaryTeal,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Milestones'),
                Tab(text: 'Achievements'),
                Tab(text: 'Students'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _milestonesTab(progress),
              _achievementsTab(progress),
              _studentsTab(students, progress),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.primaryTeal,
            onPressed: () => _showLogDialog(context, progress, students),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  // ---- Milestones Tab ----
  Widget _milestonesTab(ProgressProvider progress) {
    final all = List<StudentMilestone>.from(progress.milestones)..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    if (all.isEmpty) {
      return Center(child: Text('No milestones logged yet.', style: TextStyle(color: Colors.grey[500])));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: all.length,
      itemBuilder: (context, index) => _milestoneCard(all[index]),
    );
  }

  Widget _milestoneCard(StudentMilestone m) {
    final catColor = _categoryColor(m.category);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: catColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(m.category.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: catColor)),
                ),
                const SizedBox(width: 8),
                _levelBadge(m.level),
                const Spacer(),
                Text(DateFormat('MMM d').format(m.loggedAt), style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
            const SizedBox(height: 8),
            Text(m.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(m.description, style: const TextStyle(fontSize: 13)),
            if (m.evidence != null) ...[
              const SizedBox(height: 4),
              Text('📝 ${m.evidence}', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey[600])),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${m.classroom} · ${m.teacherName}', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                const Spacer(),
                Icon(Icons.visibility, size: 12, color: m.isSharedWithParent ? const Color(0xFF16A34A) : Colors.grey[300]),
                const SizedBox(width: 2),
                Text(m.isSharedWithParent ? 'Shared' : 'Private', style: TextStyle(fontSize: 10, color: m.isSharedWithParent ? const Color(0xFF16A34A) : Colors.grey[400])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelBadge(MilestoneLevel l) {
    final color = l == MilestoneLevel.advanced ? const Color(0xFF16A34A)
        : l == MilestoneLevel.proficient ? AppTheme.primaryTeal
        : l == MilestoneLevel.developing ? AppTheme.alertAmber : AppTheme.secondaryCoral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(l.name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  // ---- Achievements Tab ----
  Widget _achievementsTab(ProgressProvider progress) {
    final all = progress.publicAchievements;
    if (all.isEmpty) {
      return Center(child: Text('No achievements yet.', style: TextStyle(color: Colors.grey[500])));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: all.length,
      itemBuilder: (context, index) {
        final a = all[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.alertAmber, Color(0xFFEA580C)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${a.studentName} · ${a.classroom}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 2),
                      Text(a.description, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- Students Tab (select to view detail) ----
  Widget _studentsTab(List students, ProgressProvider progress) {
    if (students.isEmpty) {
      return Center(child: Text('No students enrolled.', style: TextStyle(color: Colors.grey[500])));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final s = students[index];
        final msCount = progress.milestonesForStudent(s.id).length;
        final achCount = progress.achievementsForStudent(s.id).length;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.08),
              child: Text(s.name[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
            ),
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$msCount milestones · $achCount achievements', style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => setState(() => _selectedStudentId = s.id),
          ),
        );
      },
    );
  }

  // ---- Student Detail View ----
  Widget _studentDetailView(BuildContext context, ProgressProvider progress, student) {
    final milestones = progress.milestonesForStudent(student.id);
    final achievements = progress.achievementsForStudent(student.id);
    final byCategory = progress.milestonesByCategory(student.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _selectedStudentId = null)),
        title: Text(student.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primaryTeal, Color(0xFF0F766E)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32, backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(student.name[0].toUpperCase(), style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Text(student.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(student.classroom, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statBadge('${milestones.length}', 'Milestones'),
                      _statBadge('${achievements.length}', 'Achievements'),
                      _statBadge('${byCategory.length}', 'Categories'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Achievements
            if (achievements.isNotEmpty) ...[
              const Text('Achievements', style: kTitleMedium),
              const SizedBox(height: 8),
              ...achievements.map((a) => Card(
                margin: const EdgeInsets.only(bottom: 8), elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.emoji_events_rounded, color: AppTheme.alertAmber),
                  title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(a.description, style: const TextStyle(fontSize: 12)),
                ),
              )),
              const SizedBox(height: 16),
            ],

            // Milestones by category
            const Text('Developmental Milestones', style: kTitleMedium),
            const SizedBox(height: 8),
            if (byCategory.isEmpty)
              Text('No milestones recorded yet.', style: TextStyle(color: Colors.grey[500]))
            else
              ...byCategory.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _categoryColor(entry.key).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(entry.key.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _categoryColor(entry.key))),
                      ),
                      const SizedBox(width: 8),
                      Text('${entry.value.length} record(s)', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ]),
                  ),
                  ...entry.value.map((m) => _milestoneCard(m)),
                ],
              )),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }

  Color _categoryColor(MilestoneCategory c) {
    switch (c) {
      case MilestoneCategory.social: return const Color(0xFF2563EB);
      case MilestoneCategory.creative: return const Color(0xFF9333EA);
      case MilestoneCategory.cognitive: return AppTheme.primaryTeal;
      case MilestoneCategory.physical: return const Color(0xFFEA580C);
      case MilestoneCategory.language: return const Color(0xFF16A34A);
      case MilestoneCategory.emotional: return AppTheme.secondaryCoral;
    }
  }

  // ---- Log milestone / achievement dialog ----
  void _showLogDialog(BuildContext context, ProgressProvider progress, List students) {
    final studentCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    MilestoneCategory category = MilestoneCategory.social;
    MilestoneLevel level = MilestoneLevel.developing;
    bool shareParent = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Log Milestone', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Student *'),
                  items: students.map<DropdownMenuItem<String>>((s) =>
                      DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.classroom})'))).toList(),
                  onChanged: (v) {},
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<MilestoneCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: MilestoneCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (v) => setDialogState(() => category = v ?? MilestoneCategory.social),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<MilestoneLevel>(
                  value: level,
                  decoration: const InputDecoration(labelText: 'Level'),
                  items: MilestoneLevel.values.map((l) => DropdownMenuItem(value: l, child: Text(l.name))).toList(),
                  onChanged: (v) => setDialogState(() => level = v ?? MilestoneLevel.developing),
                ),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description *'), maxLines: 3),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Share with parent', style: TextStyle(fontSize: 14)),
                  value: shareParent, onChanged: (v) => setDialogState(() => shareParent = v),
                  dense: true, contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () {
                if (descCtrl.text.trim().isEmpty) return;
                // Use first student if none selected
                final s = students.isNotEmpty ? students.first : null;
                if (s == null) return;
                progress.logMilestone(
                  studentId: s.id, studentName: s.name, classroom: s.classroom,
                  teacherName: 'Teacher', teacherId: 'current',
                  description: descCtrl.text.trim(), category: category,
                  level: level, shareWithParent: shareParent,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Log', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
