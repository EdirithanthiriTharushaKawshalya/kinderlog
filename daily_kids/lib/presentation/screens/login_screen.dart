import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import 'teacher_login_screen.dart';
import 'management_login_screen.dart';

class LoginScreen extends StatelessWidget {
  final bool isFirstSetup;

  const LoginScreen({super.key, this.isFirstSetup = false});

  @override
  Widget build(BuildContext context) {
    return LoginBackground(
      header: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.png',
            width: 72,
            height: 72,
          ),
          const SizedBox(height: 12),
          Text(
            'DailyKids',
            style: kTitleLarge.copyWith(
              fontSize: 30,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'PRESCHOOL',
            style: kBodyMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Text(
            isFirstSetup ? 'Welcome! Let\'s set up your preschool.' : 'Welcome back!',
            style: kBodyMedium.copyWith(
              fontSize: 15,
              color: const Color(0xFF1D2939),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          // Management & Teacher Login Option Cards
          _buildOptionCard(
            context,
            icon: Icons.admin_panel_settings_rounded,
            title: 'Login as Management',
            subtitle: 'View attendance across all branches & classes',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManagementLoginScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _buildOptionCard(
            context,
            icon: Icons.person_rounded,
            title: 'Login as a Teacher',
            subtitle: 'Access your class & mark attendance',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TeacherLoginScreen()),
            ),
          ),
          const SizedBox(height: 28),
          // Footer with preschool name context
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.preschool == null) return const SizedBox.shrink();
              return Text(
                auth.preschool!.name,
                style: kBodyMedium.copyWith(
                  fontSize: 13,
                  color: Colors.black38,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.08), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.black87, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: kTitleMedium.copyWith(
                      fontSize: 15,
                      color: const Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: kBodyMedium.copyWith(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}
