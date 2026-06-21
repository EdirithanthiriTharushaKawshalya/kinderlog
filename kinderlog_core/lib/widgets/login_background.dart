import 'package:flutter/material.dart';
import 'package:kinderlog_core/theme/app_theme.dart';

class LoginBackground extends StatelessWidget {
  final Widget header;
  final Widget body;
  final bool showBackButton;

  const LoginBackground({
    super.key,
    required this.header,
    required this.body,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = 280.0;

    return Scaffold(
      backgroundColor: AppTheme.primaryTeal,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section (Header)
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: headerHeight,
                  color: AppTheme.primaryTeal,
                ),
                // Concentric circles
                Positioned(
                  top: -120,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -160,
                  child: Container(
                    width: 420,
                    height: 420,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -200,
                  child: Container(
                    width: 520,
                    height: 520,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.04),
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
                // Header Content
                Positioned.fill(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Center(child: header),
                    ),
                  ),
                ),
                // Optional white rounded back button inside the header
                if (showBackButton)
                  Positioned(
                    top: 12,
                    left: 16,
                    child: SafeArea(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.maybePop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Bottom Section (Body Card)
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: screenHeight - headerHeight,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
