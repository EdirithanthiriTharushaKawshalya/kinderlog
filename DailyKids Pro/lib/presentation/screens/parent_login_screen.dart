import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import 'main_screen.dart';

class ParentLoginScreen extends StatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Parent Login'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: AppTheme.bgGrey,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Illustration
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.excusedIndigo.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.family_restroom_rounded,
                        size: 52,
                        color: AppTheme.excusedIndigo,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Login as a Parent',
                      style: kTitleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your registered email to access your child\'s updates and chat with teachers.',
                      style: kBodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Parent Email',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                        hintText: 'parent@email.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                      onFieldSubmitted: (_) => _handleLogin(auth),
                    ),
                    const SizedBox(height: 20),
                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : () => _handleLogin(auth),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.excusedIndigo,
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Login', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    // Error
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.secondaryCoral, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(fontSize: 12, color: AppTheme.secondaryCoral),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    // Pre-filled demo emails hint
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, size: 14, color: AppTheme.excusedIndigo),
                              SizedBox(width: 6),
                              Text(
                                'Demo Parent Accounts',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.excusedIndigo,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildDemoEmail('john.smith@email.com', 'John Smith — Parent of Liam'),
                          _buildDemoEmail('sarah.johnson@email.com', 'Sarah Johnson — Parent of Emma'),
                          _buildDemoEmail('maria.garcia@email.com', 'Maria Garcia — Parent of Noah'),
                        ],
                      ),
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

  void _handleLogin(AuthProvider auth) async {
    if (_formKey.currentState?.validate() ?? false) {
      final ok = await auth.loginAsParent(_emailController.text.trim());
      if (ok && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildDemoEmail(String email, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          _emailController.text = email;
          setState(() {});
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2.0),
              child: Icon(Icons.email_outlined, size: 13, color: Colors.grey),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: email,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: '($description)',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
