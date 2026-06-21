import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/attendance_provider.dart';
import 'management_dashboard_screen.dart';
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
  Widget? _subPage;
  String? _subPageTitle;

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
            automaticallyImplyLeading: _subPage != null,
            leading: _subPage != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                    onPressed: () => setState(() {
                      _subPage = null;
                      _subPageTitle = null;
                    }),
                  )
                : null,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _subPageTitle ?? auth.preschool?.name ?? 'DailyKids Pro',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_subPageTitle == null && auth.isTeacher && auth.currentBranch != null)
                  Text(
                    auth.currentBranch!.name,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
              ],
            ),
            actions: _subPage != null
                ? null
                : [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 22, color: Colors.grey),
                      onSelected: (action) {
                        switch (action) {
                          case 'behavior':
                            setState(() {
                              _subPage = const BehaviorScreen(hideAppBar: true);
                              _subPageTitle = 'Behavior Logs';
                            });
                            break;
                          case 'calendar':
                            setState(() {
                              _subPage = const CalendarScreen(hideAppBar: true);
                              _subPageTitle = 'School Calendar';
                            });
                            break;
                          case 'progress':
                            setState(() {
                              _subPage = const ProgressScreen(hideAppBar: true);
                              _subPageTitle = 'Progress Tracking';
                            });
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
                        const PopupMenuItem(
                          value: 'calendar',
                          child: ListTile(
                            leading: Icon(Icons.calendar_month_rounded, size: 20),
                            title: Text('School Calendar', style: TextStyle(fontSize: 14)),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'progress',
                          child: ListTile(
                            leading: Icon(Icons.trending_up_rounded, size: 20),
                            title: Text('Progress Tracking', style: TextStyle(fontSize: 14)),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'behavior',
                          child: ListTile(
                            leading: Icon(Icons.report_problem_outlined, size: 20),
                            title: Text('Behavior Logs', style: TextStyle(fontSize: 14)),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.logout_rounded, size: 20, color: AppTheme.secondaryCoral),
                            title: Text('Logout', style: TextStyle(fontSize: 14, color: AppTheme.secondaryCoral)),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
          ),
          body: _subPage ?? IndexedStack(index: _currentIndex, children: screens),
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
                  onDestinationSelected: (index) => setState(() {
                    _currentIndex = index;
                    _subPage = null;
                    _subPageTitle = null;
                  }),
                  indicatorColor: Colors.black.withOpacity(0.06),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: isTeacher || isParent
                      ? const [
                          NavigationDestination(
                            icon: Icon(Icons.chat_bubble_outline_rounded, color: Colors.black45),
                            selectedIcon: Icon(Icons.chat_bubble_rounded, color: Colors.black87),
                            label: 'Messages',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.assignment_outlined, color: Colors.black45),
                            selectedIcon: Icon(Icons.assignment_rounded, color: Colors.black87),
                            label: 'Homework',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.calendar_month_outlined, color: Colors.black45),
                            selectedIcon: Icon(Icons.calendar_month_rounded, color: Colors.black87),
                            label: 'Calendar',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.notifications_outlined, color: Colors.black45),
                            selectedIcon: Icon(Icons.notifications_rounded, color: Colors.black87),
                            label: 'Alerts',
                          ),
                        ]
                      : const [
                          NavigationDestination(
                            icon: Icon(Icons.grid_view_outlined, color: Colors.black45),
                            selectedIcon: Icon(Icons.grid_view_rounded, color: Colors.black87),
                            label: 'Dashboard',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.payment_outlined, color: Colors.black45),
                            selectedIcon: Icon(Icons.payment_rounded, color: Colors.black87),
                            label: 'Fees',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.notifications_outlined, color: Colors.black45),
                            selectedIcon: Icon(Icons.notifications_rounded, color: Colors.black87),
                            label: 'Alerts',
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
}
