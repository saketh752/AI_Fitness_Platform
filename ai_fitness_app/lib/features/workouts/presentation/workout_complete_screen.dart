import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../data/workout_api_service.dart';
import 'workout_plan_state.dart';
import 'workout_session.dart';

class WorkoutCompleteScreen extends StatefulWidget {
  const WorkoutCompleteScreen({required this.workout, super.key});

  final WorkoutItem workout;

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _circleScaleAnimation;
  late final Animation<double> _checkOpacityAnimation;
  late final Animation<double> _titleOpacityAnimation;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _summaryOpacityAnimation;
  late final Animation<Offset> _summarySlideAnimation;
  late final Animation<double> _streakOpacityAnimation;
  late final Animation<double> _ctaOpacityAnimation;
  bool _isDoneNavigating = false;

  @override
  void initState() {
    super.initState();
    _syncWorkoutToBackend();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 0 - 400ms: Success circle scale (0.8 -> 1.05 -> 1.0)
    _circleScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.05).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.40),
      ),
    );

    // Check appears ~250ms later (0.25 to 0.45)
    _checkOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.25, 0.45, curve: Curves.easeIn),
      ),
    );

    // Title / Subtitle fade & slight slide (0.30 to 0.60)
    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.30, 0.60, curve: Curves.easeOut),
      ),
    );
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.30, 0.60, curve: Curves.easeOut),
      ),
    );

    // Summary fade / slide (0.45 to 0.75) (~300-350ms)
    _summaryOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
      ),
    );
    _summarySlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
      ),
    );

    // Streak fade ~250ms (0.65 to 0.90)
    _streakOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.65, 0.90, curve: Curves.easeIn),
      ),
    );

    // CTA last (0.75 to 1.0)
    _ctaOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDone() {
    if (_isDoneNavigating) return;
    setState(() => _isDoneNavigating = true);

    WorkoutPlanState.markTodayCompleted();
    WorkoutSessionStore.clear(widget.workout.id);

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.workoutOverview,
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutTitle = widget.workout.name.split(':').first;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 38,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(),
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) => Transform.scale(
                        scale: _circleScaleAnimation.value,
                        child: Container(
                          width: 74,
                          height: 74,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: Opacity(
                            opacity: _checkOpacityAnimation.value,
                            child: const Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                              size: 42,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) => SlideTransition(
                        position: _titleSlideAnimation,
                        child: Opacity(
                          opacity: _titleOpacityAnimation.value,
                          child: Column(
                            children: [
                              const Text(
                                'Workout Complete!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Great work, Arjun! 👏\nYou finished today\'s\n$workoutTitle workout.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) => SlideTransition(
                        position: _summarySlideAnimation,
                        child: Opacity(
                          opacity: _summaryOpacityAnimation.value,
                          child: _summary(),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) => Opacity(
                        opacity: _streakOpacityAnimation.value,
                        child: const Text(
                          '🔥  5 Day Streak',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) => Opacity(
                        opacity: _ctaOpacityAnimation.value,
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isDoneNavigating ? null : _onDone,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summary() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WORKOUT SUMMARY',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _value(widget.workout.duration, 'Duration'),
            const SizedBox(width: 52),
            _value('${widget.workout.exerciseCount}', 'Exercises'),
          ],
        ),
        const SizedBox(height: 12),
        _value('320 kcal', 'Estimated Burn'),
        const SizedBox(height: 12),
        _value(widget.workout.equipment, 'Equipment'),
      ],
    ),
  );

  Widget _value(String value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    ],
  );

  Future<void> _syncWorkoutToBackend() async {
    try {
      await WorkoutApiService().logCompletedWorkout(
        workoutName: widget.workout.name,
        durationMinutes: 45,
        caloriesBurned: 320,
        exercisesCompleted: widget.workout.exercises.isNotEmpty ? widget.workout.exercises.length : 5,
      );
    } catch (_) {
      // Graceful offline fallback
    }
  }
}
