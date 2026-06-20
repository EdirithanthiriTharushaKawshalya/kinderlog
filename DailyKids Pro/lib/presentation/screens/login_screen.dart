import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import 'management_setup_screen.dart';
import 'teacher_login_screen.dart';
import 'parent_login_screen.dart';
import 'management_dashboard_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatelessWidget {
  final bool isFirstSetup;

  const LoginScreen({super.key, this.isFirstSetup = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryTeal, Color(0xFF0F766E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.child_care_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'DailyKids',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Welcome message
                  Text(
                    isFirstSetup ? 'Welcome! Let\'s set up your preschool.' : 'Welcome back!',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // -- First Launch: Setup button --
                  if (isFirstSetup) ...[
                    _buildOptionCard(
                      context,
                      icon: Icons.school_rounded,
                      title: 'Create Preschool Profile',
                      subtitle: 'Set up your preschool with branches & classes',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManagementSetupScreen()),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildOptionCard(
                      context,
                      icon: Icons.login_rounded,
                      title: 'I\'m a Teacher',
                      subtitle: 'Login with your authorized email',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TeacherLoginScreen()),
                      ),
                    ),
                  ],
                  // -- Existing preschool: Management, Teacher, & Parent login --
                  if (!isFirstSetup) ...[
                    _buildOptionCard(
                      context,
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Login as Management',
                      subtitle: 'Manage branches, classes, admissions & more',
                      onTap: () => _showManagementLogin(context),
                    ),
                    const SizedBox(height: 14),
                    _buildOptionCard(
                      context,
                      icon: Icons.person_rounded,
                      title: 'Login as a Teacher',
                      subtitle: 'Access messaging, calendar & progress tracking',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TeacherLoginScreen()),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildOptionCard(
                      context,
                      icon: Icons.family_restroom_rounded,
                      title: 'Login as a Parent',
                      subtitle: 'Chat with teachers & track your child\'s progress',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ParentLoginScreen()),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Footer with preschool name context
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.preschool == null) return const SizedBox.shrink();
                      return Text(
                        auth.preschool!.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showManagementLogin(BuildContext context) {
    final emailController = TextEditingController(
      text: 'admin@dailykids.com',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primaryTeal, size: 24),
                  SizedBox(width: 10),
                  Text('Management Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enter your management email to continue.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        auth.errorMessage!,
                        style: const TextStyle(color: AppTheme.secondaryCoral, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() ?? false) {
                            final success = await auth.loginAsManagement(emailController.text.trim());
                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const MainScreen()),
                                (route) => false,
                              );
                            }
                          }
                        },
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Login', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.primaryTeal, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }
}
