import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/attendance_provider.dart';
import 'dashboard_screen.dart';
import 'attendance_marking_screen.dart';
import 'roster_screen.dart';
import 'teacher_login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      DashboardScreen(),
      AttendanceMarkingScreen(),
      RosterScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final attendance = context.read<AttendanceProvider>();
      attendance.initialize(auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AttendanceProvider>(
      builder: (context, auth, attendance, _) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.isSubstituteMode
                      ? 'Sub: ${attendance.substituteBranchName ?? ""}'
                      : auth.currentBranch?.name ?? 'KinderLog',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (auth.isTeacher && auth.currentUser?.pinnedClassId != null) ...[
                  Text('Class: ${attendance.selectedClassFilter}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ],
            ),
            actions: [
              // Pin class
              if (auth.isTeacher)
                PopupMenuButton<String>(
                  icon: Icon(
                    attendance.activeClassId != null ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: attendance.activeClassId != null ? AppTheme.primaryTeal : Colors.grey[600],
                    size: 22,
                  ),
                  tooltip: 'Pin/Substitute',
                  onSelected: (action) {
                    if (action == 'pin') _showPinClassDialog(context, auth, attendance);
                    if (action == 'sub') _showSubstituteDialog(context, auth, attendance);
                    if (action == 'exit_sub') attendance.exitSubstituteMode();
                  },
                  itemBuilder: (context) => [
                    if (attendance.isSubstituteMode)
                      const PopupMenuItem(value: 'exit_sub', child: Text('Exit Substitute Mode')),
                    if (!attendance.isSubstituteMode) ...[
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(attendance.activeClassId != null ? 'Change Pinned Class' : 'Pin a Class'),
                      ),
                      const PopupMenuItem(value: 'sub', child: Text('Substitute Teacher Mode')),
                    ],
                  ],
                ),
              // Logout only
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 22, color: Colors.grey),
                onSelected: (action) {
                  if (action == 'logout') {
                    auth.logout();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TeacherLoginScreen()));
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'logout', child: ListTile(
                    leading: const Icon(Icons.logout_rounded, size: 20, color: AppTheme.secondaryCoral),
                    title: const Text('Logout', style: TextStyle(fontSize: 14, color: AppTheme.secondaryCoral)),
                    dense: true, contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              if (attendance.isSubstituteMode)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.alertAmber.withValues(alpha: 0.15),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz_rounded, size: 16, color: AppTheme.alertAmber),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Substitute: ${attendance.substituteBranchName}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.alertAmber))),
                      TextButton(onPressed: () => attendance.exitSubstituteMode(), child: const Text('Exit', style: TextStyle(fontSize: 12))),
                    ],
                  ),
                ),
              Expanded(
                child: IndexedStack(index: _currentIndex, children: _screens),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            indicatorColor: AppTheme.primaryTeal.withValues(alpha: 0.12),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryTeal),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.how_to_reg_outlined),
                selectedIcon: Icon(Icons.how_to_reg_rounded, color: AppTheme.primaryTeal),
                label: 'Attendance',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline_rounded),
                selectedIcon: Icon(Icons.people_alt_rounded, color: AppTheme.primaryTeal),
                label: 'Roster',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPinClassDialog(BuildContext context, AuthProvider auth, AttendanceProvider attendance) {
    final classes = auth.currentBranchClasses;
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No classes available.')));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Pin a Class', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: classes.map((c) => ListTile(
            leading: Icon(attendance.activeClassId == c.id ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: attendance.activeClassId == c.id ? AppTheme.primaryTeal : Colors.grey),
            title: Text(c.name),
            onTap: () {
              if (attendance.activeClassId == c.id) { attendance.unpinClass(); }
              else { attendance.pinClass(c.id); }
              Navigator.pop(ctx);
            },
          )).toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  void _showSubstituteDialog(BuildContext context, AuthProvider auth, AttendanceProvider attendance) {
    final otherBranches = auth.branches.where((b) => b.id != auth.currentUser?.branchId).toList();
    if (otherBranches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No other branches available.')));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Substitute Teacher', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: otherBranches.map((b) => ListTile(
            leading: const Icon(Icons.swap_horiz_rounded, color: AppTheme.alertAmber),
            title: Text(b.name),
            subtitle: Text(b.location.isNotEmpty ? b.location : '', style: const TextStyle(fontSize: 11)),
            onTap: () { attendance.enterSubstituteMode(b); Navigator.pop(ctx); },
          )).toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
      ),
    );
  }
}
