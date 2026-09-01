import 'package:flutter/material.dart';
import 'package:ai_fitness_app/app/theme/app_colors.dart';

import '../../../app/routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // Compact top branding/content group (constrained for two-line title)
              LayoutBuilder(builder: (context, constraints) {
                final maxTextWidth = constraints.maxWidth * 0.78;
                return Transform.translate(
                  offset: const Offset(5, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.fitness_center,
                          color: AppColors.primary,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxTextWidth),
                      child: Text(
                        'Fitness that fits your\nreal life.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxTextWidth),
                      child: Text(
                        'Personalized fitness based on your goals, available food, equipment, budget, and time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),
              const Spacer(),

              // Center illustration (simple abstract using CustomPaint)
              Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: _WelcomeIllustrationPainter(),
                  ),
                ),
              ),

              const Spacer(),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signup);
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Dashed circular outline
    final circlePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const dash = 6.0;
    const gap = 6.0;
    final radius = size.width * 0.42;
    double startAngle = 0;
    final circumference = 2 * 3.14159 * radius;
    final segments = (circumference / (dash + gap)).floor();
    for (int i = 0; i < segments; i++) {
      final a1 = startAngle + i * (dash + gap) / radius;
      final a2 = a1 + dash / radius;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), a1, a2 - a1, false, circlePaint);
    }

    // Central person-like shape (simple rounded rectangle + circle)
    final bodyPaint = Paint()..color = AppColors.primary;
    final headRadius = size.width * 0.08;
    final headCenter = Offset(center.dx, center.dy - size.height * 0.06);
    canvas.drawCircle(headCenter, headRadius, bodyPaint);

    final bodyRect = Rect.fromCenter(center: Offset(center.dx, center.dy + size.height * 0.06), width: size.width * 0.28, height: size.height * 0.28);
    final rrect = RRect.fromRectAndRadius(bodyRect, Radius.circular(12));
    canvas.drawRRect(rrect, bodyPaint);

    // Decorative dots
    final dotPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.6);
    canvas.drawCircle(Offset(center.dx - size.width * 0.36, center.dy - size.height * 0.18), 3, dotPaint);
    canvas.drawCircle(Offset(center.dx + size.width * 0.34, center.dy + size.height * 0.12), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
