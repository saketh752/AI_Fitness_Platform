import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import 'workout_plan_state.dart';

class WorkoutOverviewScreen extends StatelessWidget {
  const WorkoutOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: WorkoutOverviewContent(
          onOpenDetails: (workout) => Navigator.pushNamed(
            context,
            AppRoutes.workoutDetails,
            arguments: workout,
          ),
        ),
      ),
    );
  }
}

class WorkoutOverviewContent extends StatefulWidget {
  const WorkoutOverviewContent({required this.onOpenDetails, super.key});

  final ValueChanged<WorkoutItem> onOpenDetails;

  @override
  State<WorkoutOverviewContent> createState() => _WorkoutOverviewContentState();
}

class _WorkoutOverviewContentState extends State<WorkoutOverviewContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  bool _openingDetails = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _openDetails(WorkoutItem workout) {
    if (_openingDetails) return;
    setState(() => _openingDetails = true);
    widget.onOpenDetails(workout);
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _openingDetails = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _reveal(0, _header()),
          const SizedBox(height: 22),
          _reveal(1, _weeklyCompletion()),
          const SizedBox(height: 10),
          _reveal(2, _todayWorkout()),
          const SizedBox(height: 10),
          _reveal(3, _schedule()),
        ],
      ),
    );
  }

  Widget _header() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Your Training Plan',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        WorkoutPlanState.goal,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 25,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 3),
      const Text(
        '${WorkoutPlanState.week} · Personalized for you',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    ],
  );

  Widget _weeklyCompletion() => _card(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weekly Completion',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${WorkoutPlanState.completedWorkouts} of ${WorkoutPlanState.targetWorkouts} workouts',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: WorkoutPlanState.completion),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) => ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _todayWorkout() => _card(
    onTap: () => _openDetails(WorkoutPlanState.today),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _badge("TODAY'S WORKOUT"),
            const Text(
              WorkoutPlanState.todayDay,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 11),
        const Text(
          WorkoutPlanState.todayName,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          WorkoutPlanState.todayDetails,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        if (WorkoutPlanState.today.status == WorkoutStatus.completed)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Workout Complete',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else ...[
          const SizedBox(height: 10),
          _pressButton(
            'Start Workout',
            () => _openDetails(WorkoutPlanState.today),
          ),
        ],
      ],
    ),
  );

  Widget _schedule() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(left: 20, bottom: 8),
        child: Text(
          'This Week',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      ...WorkoutPlanState.schedule.map(
        (workout) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: WorkoutDayCard(
            workout: workout,
            onTap: workout.status == WorkoutStatus.rest
                ? null
                : () => _openDetails(workout),
          ),
        ),
      ),
    ],
  );

  Widget _reveal(int index, Widget child) {
    final start = (index * .12).clamp(0.0, .55);
    final animation = CurvedAnimation(
      parent: _entryController,
      curve: Interval(start, (start + .45).clamp(0.0, 1.0)),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .04),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Widget _card({required Widget child, VoidCallback? onTap}) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.shade300),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );

  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text(
      "TODAY'S WORKOUT",
      style: TextStyle(
        color: AppColors.primary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _pressButton(String text, VoidCallback onTap) => AnimatedScale(
    scale: _openingDetails ? .98 : 1,
    duration: const Duration(milliseconds: 110),
    child: SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _openingDetails ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

class WorkoutDayCard extends StatefulWidget {
  const WorkoutDayCard({required this.workout, this.onTap, super.key});

  final WorkoutItem workout;
  final VoidCallback? onTap;

  @override
  State<WorkoutDayCard> createState() => _WorkoutDayCardState();
}

class _WorkoutDayCardState extends State<WorkoutDayCard> {
  bool _pressed = false;
  bool _opening = false;

  void _tap() {
    if (_opening || widget.onTap == null) return;
    setState(() {
      _pressed = true;
      _opening = true;
    });
    widget.onTap!();
    Future<void>.delayed(const Duration(milliseconds: 280), () {
      if (mounted) {
        setState(() {
          _pressed = false;
          _opening = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRest = widget.workout.status == WorkoutStatus.rest;
    final isCompleted = widget.workout.status == WorkoutStatus.completed;
    return AnimatedScale(
      scale: _pressed ? .98 : 1,
      duration: const Duration(milliseconds: 110),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: InkWell(
          onTap: isRest ? null : _tap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Row(
              children: [
                Text(
                  isRest
                      ? '↻'
                      : isCompleted
                      ? '✓'
                      : '○',
                  style: TextStyle(
                    color: isCompleted
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    widget.workout.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  widget.workout.detail,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
