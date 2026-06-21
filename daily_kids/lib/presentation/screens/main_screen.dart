import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/attendance_provider.dart';
import 'dashboard_screen.dart';
import 'attendance_marking_screen.dart';
import 'roster_screen.dart';
import 'management_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final attendance = context.read<AttendanceProvider>();
      attendance.initialize(auth);
    });
  }

  // ── Role-specific screen lists ──────────────────────────
  static const _teacherScreens = [
    DashboardScreen(),
    AttendanceMarkingScreen(),
    RosterScreen(),
  ];

  static const _managementScreens = [
    DashboardScreen(),
    ManagementScreen(),
    RosterScreen(),
  ];

  List<Widget> _getScreens(AuthProvider auth) {
    return auth.isManagement ? _managementScreens : _teacherScreens;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AttendanceProvider>(
      builder: (context, auth, attendance, _) {
        final screens = _getScreens(auth);
        final isManagement = auth.isManagement;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: _buildAppBarTitle(auth, attendance, isManagement),
            actions: [
              if (isManagement)
                _buildBranchFilter(auth, attendance)
              else ...[
                // Teacher: Pin class & Substitute
                _buildTeacherActions(auth, attendance),
              ],
              // Logout
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 22, color: Colors.grey),
                onSelected: (action) {
                  if (action == 'logout') {
                    auth.logout();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'logout', child: ListTile(
                    leading: Icon(Icons.logout_rounded, size: 20, color: AppTheme.secondaryCoral),
                    title: Text('Logout', style: TextStyle(fontSize: 14, color: AppTheme.secondaryCoral)),
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
                child: IndexedStack(index: _currentIndex, children: screens),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: SafeArea(
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  height: 64,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  indicatorColor: Colors.black.withOpacity(0.06),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: isManagement
                      ? const [
                          NavigationDestination(
                            icon: Icon(Icons.grid_view_outlined, color: Colors.black45),
                            selectedIcon: Icon(Icons.grid_view_rounded, color: Colors.black87),
                            label: 'Dashboard',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.tune_outlined, color: Colors.black45),
                            selectedIcon: Icon(Icons.tune_rounded, color: Colors.black87),
                            label: 'Manage',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.badge_outlined, color: Colors.black45),
                            selectedIcon: Icon(Icons.badge_rounded, color: Colors.black87),
                            label: 'Roster',
                          ),
                        ]
                      : const [
                          NavigationDestination(
                            icon: Icon(Icons.grid_view_outlined, color: Colors.black45),
                            selectedIcon: Icon(Icons.grid_view_rounded, color: Colors.black87),
                            label: 'Dashboard',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.fact_check_outlined, color: Colors.black45),
                            selectedIcon: Icon(Icons.fact_check_rounded, color: Colors.black87),
                            label: 'Attendance',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.badge_outlined, color: Colors.black45),
                            selectedIcon: Icon(Icons.badge_rounded, color: Colors.black87),
                            label: 'Roster',
                          ),
                        ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── App Bar Title ───────────────────────────────────────
  Widget _buildAppBarTitle(AuthProvider auth, AttendanceProvider attendance, bool isManagement) {
    if (attendance.isSubstituteMode) {
      return Text('Sub: ${attendance.substituteBranchName ?? ""}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    }
    if (isManagement) {
      return const Text('DailyKids',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          auth.currentBranch?.name ?? 'DailyKids',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (auth.currentUser?.pinnedClassId != null)
          Text('Class: ${attendance.selectedClassFilter}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  // ── Management: Branch filter dropdown ───────────────────
  Widget _buildBranchFilter(AuthProvider auth, AttendanceProvider attendance) {
    final branches = auth.branches;
    final allLabel = 'All Branches';
    final currentLabel = attendance.activeBranchId.isEmpty
        ? allLabel
        : branches.where((b) => b.id == attendance.activeBranchId).firstOrNull?.name ?? allLabel;

    return PopupMenuButton<String>(
      onSelected: (branchId) {
        attendance.setBranchFilter(branchId.isEmpty ? null : branchId);
      },
      offset: const Offset(0, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryTeal.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.primaryTeal, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: '',
          child: Row(
            children: [
              Icon(Icons.language_rounded, size: 18, color: attendance.activeBranchId.isEmpty ? AppTheme.primaryTeal : Colors.grey),
              const SizedBox(width: 8),
              Text(allLabel, style: TextStyle(fontWeight: attendance.activeBranchId.isEmpty ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
        ...branches.map((b) => PopupMenuItem(
          value: b.id,
          child: Row(
            children: [
              Icon(Icons.school_rounded, size: 18, color: attendance.activeBranchId == b.id ? AppTheme.primaryTeal : Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text(b.name, style: TextStyle(fontWeight: attendance.activeBranchId == b.id ? FontWeight.bold : FontWeight.normal))),
            ],
          ),
        )),
      ],
    );
  }

  // ── Teacher: Pin class & Substitute ─────────────────────
  Widget _buildTeacherActions(AuthProvider auth, AttendanceProvider attendance) {
    return PopupMenuButton<String>(
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
