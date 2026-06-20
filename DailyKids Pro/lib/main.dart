import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import 'providers/attendance_provider.dart';
import 'providers/admission_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/behavior_provider.dart';
import 'providers/website_provider.dart';
import 'providers/homework_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.tryInitialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<AttendanceProvider>(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider<AdmissionProvider>(create: (_) => AdmissionProvider()),
        ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
        ChangeNotifierProvider<NotificationProvider>(create: (_) => NotificationProvider()),
        ChangeNotifierProvider<PaymentProvider>(create: (_) => PaymentProvider()),
        ChangeNotifierProvider<CalendarProvider>(create: (_) => CalendarProvider()),
        ChangeNotifierProvider<ProgressProvider>(create: (_) => ProgressProvider()),
        ChangeNotifierProvider<BehaviorProvider>(create: (_) => BehaviorProvider()),
        ChangeNotifierProvider<WebsiteProvider>(create: (_) => WebsiteProvider()),
        ChangeNotifierProvider<HomeworkProvider>(create: (_) => HomeworkProvider()),
      ],
      child: MaterialApp(
        title: 'DailyKids Pro',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
