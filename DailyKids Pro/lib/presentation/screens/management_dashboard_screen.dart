import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import 'main_screen.dart';
import 'admission_review_screen.dart';
import 'fee_dashboard_screen.dart';
import 'notifications_screen.dart';
import 'calendar_screen.dart';
import 'progress_screen.dart';
import 'behavior_screen.dart';
import 'login_screen.dart';

/// Management-level dashboard: see all branches, classes, teachers, and analytics.
class ManagementDashboardScreen extends StatefulWidget {
  final bool hideAppBar;
  const ManagementDashboardScreen({super.key, this.hideAppBar = false});

  @override
  State<ManagementDashboardScreen> createState() => _ManagementDashboardScreenState();
}

class _ManagementDashboardScreenState extends State<ManagementDashboardScreen> {
  int _selectedTab = 0; // 0: Overview, 1: Branches, 2: Classes, 3: Teachers

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          appBar: widget.hideAppBar
              ? null
              : AppBar(
                  title: Text(auth.preschool?.name ?? 'Management'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryTeal),
                      tooltip: 'Add Branch',
                      onPressed: () => _showAddBranchDialog(context, auth),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'logout') {
                          auth.logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        } else if (value == 'open_app') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MainScreen()),
                          );
                        } else if (value == 'admissions') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdmissionReviewScreen()));
                        } else if (value == 'fees') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeDashboardScreen()));
                        } else if (value == 'notifications') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                        } else if (value == 'calendar') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
                        } else if (value == 'progress') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen()));
                        } else if (value == 'behavior') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BehaviorScreen()));
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'admissions', child: Text('Admission Review')),
                        const PopupMenuItem(value: 'fees', child: Text('Fees & Payments')),
                        const PopupMenuItem(value: 'notifications', child: Text('Notifications')),
                        const PopupMenuItem(value: 'calendar', child: Text('School Calendar')),
                        const PopupMenuItem(value: 'progress', child: Text('Progress Tracking')),
                        const PopupMenuItem(value: 'behavior', child: Text('Behavior Logs')),
                        const PopupMenuItem(value: 'open_app', child: Text('Open Teacher View')),
                        const PopupMenuItem(value: 'logout', child: Text('Logout')),
                      ],
                    ),
                  ],
                ),
          body: Column(
            children: [
              // Tab bar
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    _tabButton('Overview', 0),
                    _tabButton('Branches', 1),
                    _tabButton('Classes', 2),
                    _tabButton('Teachers', 3),
                  ],
                ),
              ),
              Expanded(
                child: _selectedTab == 0
                    ? _overviewTab(auth)
                    : _selectedTab == 1
                        ? _branchesTab(auth)
                        : _selectedTab == 2
                            ? _classesTab(auth)
                            : _teachersTab(auth),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppTheme.primaryTeal : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  // ---- Overview Tab ----
  Widget _overviewTab(AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              _summaryCard('Branches', '${auth.branches.length}', Icons.location_city_rounded, AppTheme.primaryTeal),
              const SizedBox(width: 12),
              _summaryCard('Classes', '${auth.classes.length}', Icons.meeting_room_rounded, AppTheme.excusedIndigo),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryCard('Teachers', '${auth.users.where((u) => u.role == UserRole.teacher).length}',
                  Icons.people_rounded, AppTheme.alertAmber),
              const SizedBox(width: 12),
              _summaryCard('Students', '---', Icons.child_care_rounded, const Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Quick Actions', style: kTitleMedium),
          const SizedBox(height: 12),
          _actionCard(
            icon: Icons.location_city_rounded,
            title: 'Add New Branch',
            subtitle: 'Create a new physical location',
            onTap: () => _showAddBranchDialog(context, auth),
          ),
          const SizedBox(height: 8),
          _actionCard(
            icon: Icons.meeting_room_rounded,
            title: 'Add New Class',
            subtitle: 'Create a class within a branch',
            onTap: () => _showAddClassDialog(context, auth),
          ),
          const SizedBox(height: 8),
          _actionCard(
            icon: Icons.person_add_rounded,
            title: 'Add New Teacher',
            subtitle: 'Authorize a teacher login account',
            onTap: () => _showAddTeacherDialog(context, auth),
          ),
          const SizedBox(height: 8),
          _actionCard(
            icon: Icons.open_in_new_rounded,
            title: 'Open Teacher View',
            subtitle: 'See the app as a teacher would',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScreen())),
          ),
        ],
      ),
    );
  }

  // ---- Branches Tab ----
  Widget _branchesTab(AuthProvider auth) {
    if (auth.branches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city_rounded, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No branches yet', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Branch'),
              onPressed: () => _showAddBranchDialog(context, auth),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: auth.branches.length,
      itemBuilder: (context, index) {
        final branch = auth.branches[index];
        final classCount = auth.classesForBranch(branch.id).length;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_city_rounded, color: AppTheme.primaryTeal, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(branch.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (branch.location.isNotEmpty)
                            Text(branch.location, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.secondaryCoral),
                      onPressed: () => auth.removeBranch(branch.id),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('$classCount class(es)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- Classes Tab ----
  Widget _classesTab(AuthProvider auth) {
    if (auth.classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.meeting_room_rounded, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No classes yet', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Class'),
              onPressed: () => _showAddClassDialog(context, auth),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: auth.branches.map((branch) {
        final branchClasses = auth.classesForBranch(branch.id);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(branch.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryTeal)),
            ),
            ...branchClasses.map((c) {
              final teacher = auth.users.where((u) => u.id == c.teacherId).firstOrNull;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.excusedIndigo.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.meeting_room_rounded, color: AppTheme.excusedIndigo, size: 20),
                  ),
                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(teacher != null ? 'Teacher: ${teacher.name}' : 'No teacher assigned',
                      style: const TextStyle(fontSize: 11)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.secondaryCoral, size: 20),
                    onPressed: () => auth.removeClass(c.id),
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  // ---- Teachers Tab ----
  Widget _teachersTab(AuthProvider auth) {
    final teachers = auth.users.where((u) => u.role == UserRole.teacher).toList();
    if (teachers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_rounded, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No teacher accounts', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Add Teacher'),
              onPressed: () => _showAddTeacherDialog(context, auth),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        final branchName = auth.branches.where((b) => b.id == teacher.branchId).firstOrNull?.name ?? 'No branch';
        final className = teacher.pinnedClassId != null
            ? auth.classes.where((c) => c.id == teacher.pinnedClassId).firstOrNull?.name ?? '-'
            : '-';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryTeal.withOpacity(0.08),
                  child: Text(teacher.name[0].toUpperCase(),
                      style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(teacher.email, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      Text('$branchName · Class: $className', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.secondaryCoral),
                  onPressed: () => auth.removeTeacher(teacher.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- Summary Card ----
  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryTeal, size: 22),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ---- Dialogs ----
  void _showAddBranchDialog(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Branch', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Branch Name *'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: locCtrl,
              decoration: const InputDecoration(labelText: 'Location/Address'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                auth.addBranch(name: nameCtrl.text.trim(), location: locCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddClassDialog(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController();
    String? selectedBranch = auth.branches.isNotEmpty ? auth.branches.first.id : null;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Class', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedBranch,
                decoration: const InputDecoration(labelText: 'Branch *'),
                items: auth.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                onChanged: (v) => setDialogState(() => selectedBranch = v),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Class Name * (e.g. FS1)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty && selectedBranch != null) {
                  auth.addClass(branchId: selectedBranch!, name: nameCtrl.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTeacherDialog(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String? selectedBranch = auth.branches.isNotEmpty ? auth.branches.first.id : null;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Teacher', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email (for login) *'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedBranch,
                decoration: const InputDecoration(labelText: 'Branch *'),
                items: auth.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                onChanged: (v) => setDialogState(() => selectedBranch = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty && emailCtrl.text.trim().isNotEmpty && selectedBranch != null) {
                  auth.addTeacher(name: nameCtrl.text.trim(), email: emailCtrl.text.trim(), branchId: selectedBranch!);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
