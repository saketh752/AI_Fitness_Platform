import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/presentation/mock_auth_state.dart';
import '../../onboarding/data/onboarding_api_service.dart';
import 'plan_generation_state.dart';

class PlanGenerationLoadingScreen extends StatefulWidget {
  const PlanGenerationLoadingScreen({super.key});

  @override
  State<PlanGenerationLoadingScreen> createState() =>
      _PlanGenerationLoadingScreenState();
}

class _PlanGenerationLoadingScreenState
    extends State<PlanGenerationLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _generationTimer;
  int _completedItems = -1;

  static const _items = [
    'Analyzing muscle-building potential',
    'Balancing budget & protein sources',
    'Structuring 12-week workout schedule',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
      lowerBound: 1,
      upperBound: 1.04,
    )..repeat(reverse: true);
    _generationTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _completedItems = 0);
      _generationTimer = Timer.periodic(const Duration(milliseconds: 1200), (
        timer,
      ) {
        if (!mounted) return;
        if (_completedItems < _items.length) {
          setState(() => _completedItems++);
        } else {
          timer.cancel();
          _generationTimer = Timer(const Duration(milliseconds: 500), () async {
            try {
              await OnboardingApiService().completeOnboarding();
            } catch (_) {
              // Graceful fallback for offline mode
            }
            if (mounted) {
              GeneratedPlanState.markGenerated();
              MockAuthState.markOnboardingComplete();
              Navigator.pushReplacementNamed(context, AppRoutes.planReady);
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _generationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              ScaleTransition(
                scale: _pulseController,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(height: 56),
              Text(
                'Building your personalized\nplan...',
                textAlign: TextAlign.center,
                style: _title(),
              ),
              const SizedBox(height: 30),
              Text(
                'Our AI is analyzing your goals, optimizing\nyour weekly workouts, and structuring a\nrealistic nutrition strategy based on your\navailable ingredients.',
                textAlign: TextAlign.center,
                style: _body(),
              ),
              const SizedBox(height: 44),
              ..._items.asMap().entries.map(
                (entry) => _checkItem(entry.key, entry.value),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkItem(int index, String text) {
    final active = index < _completedItems || index == _completedItems;
    final complete = index < _completedItems;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: active ? 1 : .45,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: complete
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 20,
                    )
                  : active
                  ? const Icon(Icons.circle, color: AppColors.primary, size: 9)
                  : const Icon(
                      Icons.circle_outlined,
                      color: AppColors.textSecondary,
                      size: 9,
                    ),
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: _body(
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _title() => const TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
  TextStyle _body({Color color = AppColors.textSecondary}) =>
      TextStyle(color: color, fontSize: 14, height: 1.45);
}
