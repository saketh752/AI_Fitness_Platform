import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import 'plan_generation_state.dart';

class PlanReadySuccessScreen extends StatefulWidget {
  const PlanReadySuccessScreen({super.key});

  @override
  State<PlanReadySuccessScreen> createState() => _PlanReadySuccessScreenState();
}

class _PlanReadySuccessScreenState extends State<PlanReadySuccessScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            children: [
              const Spacer(),
              AnimatedScale(
                scale: _visible ? 1 : .8,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedOpacity(
                    opacity: _visible ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 42,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    Text(
                      'Your Plan is Ready!',
                      textAlign: TextAlign.center,
                      style: _title(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "We've generated a hyper-personalized routine\noptimized for your environment.",
                      textAlign: TextAlign.center,
                      style: _body(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _highlights(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _visible
                      ? () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (route) => false,
                        )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View My Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.onboardingReview,
                ),
                child: const Text('Back to Summary'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _highlights() {
    final rows = [
      (
        'WORKOUTS',
        '${GeneratedPlanState.workoutFrequency} · ${GeneratedPlanState.duration}',
        Icons.monitor_heart_outlined,
      ),
      (
        'NUTRITION TARGET',
        GeneratedPlanState.nutritionTarget,
        Icons.restaurant_menu_rounded,
      ),
      (
        'YOUR FOCUS',
        '${GeneratedPlanState.focus} · 12 Weeks',
        Icons.track_changes_rounded,
      ),
    ];
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, .08),
      duration: const Duration(milliseconds: 400),
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 400),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 22, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plan Highlights', style: _title(fontSize: 20)),
              const Divider(height: 26),
              ...rows.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Icon(row.$3, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.$1,
                              style: _body(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              row.$2,
                              style: _body(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _title({double fontSize = 30}) => TextStyle(
    color: AppColors.textPrimary,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );
  TextStyle _body({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textSecondary,
  }) => TextStyle(
    color: color,
    fontSize: fontSize,
    height: 1.4,
    fontWeight: fontWeight,
  );
}
