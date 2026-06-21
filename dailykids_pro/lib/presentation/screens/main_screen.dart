import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/attendance_provider.dart';
import 'management_dashboard_screen.dart';
import 'admission_review_screen.dart';
import 'fee_dashboard_screen.dart';
import 'chat_screen.dart';
import 'homework_screen.dart';
import 'notifications_screen.dart';
import 'calendar_screen.dart';
import 'progress_screen.dart';
import 'behavior_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _teacherScreens;
  late final List<Widget> _managementScreens;
  late final List<Widget> _parentScreens;

  @override
  void initState() {
    super.initState();
    _teacherScreens = const [
      ChatScreen(hideAppBar: true),
      HomeworkScreen(hideAppBar: true),
      CalendarScreen(hideAppBar: true),
      NotificationsScreen(hideAppBar: true),
    ];
    _managementScreens = const [
      ManagementDashboardScreen(hideAppBar: true),
      AdmissionReviewScreen(hideAppBar: true),
      FeeDashboardScreen(hideAppBar: true),
      NotificationsScreen(hideAppBar: true),
    ];
    _parentScreens = const [
      ChatScreen(hideAppBar: true),
      HomeworkScreen(hideAppBar: true),
      CalendarScreen(hideAppBar: true),
      NotificationsScreen(hideAppBar: true),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final attendance = context.read<AttendanceProvider>();
      attendance.initialize(auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isTeacher = auth.isTeacher;
        final isParent = auth.isParent;
        final screens = isTeacher
            ? _teacherScreens
            : isParent
                ? _parentScreens
                : _managementScreens;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.preschool?.name ?? 'DailyKids Pro',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (auth.isTeacher && auth.currentBranch != null)
                  Text(
                    auth.currentBranch!.name,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 22, color: Colors.grey),
                onSelected: (action) {
                  switch (action) {
                    case 'behavior':
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BehaviorScreen()));
                      break;
                    case 'calendar':
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
                      break;
                    case 'progress':
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen()));
                      break;
                    case 'logout':
                      auth.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'calendar', child: ListTile(
                    leading: Icon(Icons.calendar_month_rounded, size: 20),
                    title: Text('School Calendar', style: TextStyle(fontSize: 14)),
                    dense: true, contentPadding: EdgeInsets.zero,
                  )),
                  const PopupMenuItem(value: 'progress', child: ListTile(
                    leading: Icon(Icons.trending_up_rounded, size: 20),
                    title: Text('Progress Tracking', style: TextStyle(fontSize: 14)),
                    dense: true, contentPadding: EdgeInsets.zero,
                  )),
                  const PopupMenuItem(value: 'behavior', child: ListTile(
                    leading: Icon(Icons.report_problem_outlined, size: 20),
                    title: Text('Behavior Logs', style: TextStyle(fontSize: 14)),
                    dense: true, contentPadding: EdgeInsets.zero,
                  )),
                  const PopupMenuDivider(),
                  PopupMenuItem(value: 'logout', child: ListTile(
                    leading: const Icon(Icons.logout_rounded, size: 20, color: AppTheme.secondaryCoral),
                    title: const Text('Logout', style: TextStyle(fontSize: 14, color: AppTheme.secondaryCoral)),
                    dense: true, contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
            ],
          ),
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            indicatorColor: AppTheme.primaryTeal.withValues(alpha: 0.12),
            destinations: isTeacher || isParent
                ? const [
                    NavigationDestination(
                      icon: Icon(Icons.chat_bubble_outline_rounded),
                      selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppTheme.primaryTeal),
                      label: 'Messages',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.assignment_outlined),
                      selectedIcon: Icon(Icons.assignment_rounded, color: AppTheme.primaryTeal),
                      label: 'Homework',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month_rounded, color: AppTheme.primaryTeal),
                      label: 'Calendar',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.notifications_outlined),
                      selectedIcon: Icon(Icons.notifications_rounded, color: AppTheme.primaryTeal),
                      label: 'Alerts',
                    ),
                  ]
                : const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryTeal),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.assignment_outlined),
                      selectedIcon: Icon(Icons.assignment_rounded, color: AppTheme.primaryTeal),
                      label: 'Admissions',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.payment_outlined),
                      selectedIcon: Icon(Icons.payment_rounded, color: AppTheme.primaryTeal),
                      label: 'Fees',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.notifications_outlined),
                      selectedIcon: Icon(Icons.notifications_rounded, color: AppTheme.primaryTeal),
                      label: 'Alerts',
                    ),
                  ],
          ),
        );
      },
    );
  }
}
