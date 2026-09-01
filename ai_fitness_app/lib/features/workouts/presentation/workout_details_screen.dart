import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import 'workout_plan_state.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  const WorkoutDetailsScreen({required this.workout, super.key});

  final WorkoutItem workout;

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  bool _starting = false;
  bool _pressed = false;

  bool get _isCompleted => widget.workout.status == WorkoutStatus.completed;
  bool get _isUpcoming => widget.workout.status == WorkoutStatus.upcoming;
  bool get _canStart =>
      widget.workout.id == 'today-push-day' &&
      widget.workout.exercises.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _startWorkout() {
    if (!_canStart || _starting) return;
    setState(() {
      _starting = true;
      _pressed = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.activeWorkout,
        arguments: widget.workout,
      ).then((_) {
        if (mounted) {
          setState(() {
            _starting = false;
            _pressed = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _entryController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(.04, 0),
              end: Offset.zero,
            ).animate(_entryController),
            child: Column(
              children: [
                Expanded(child: _content()),
                _bottomAction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        const SizedBox(height: 28),
        _badge('TODAY\'S WORKOUT'),
        const SizedBox(height: 12),
        Text(widget.workout.name, style: _title(26)),
        const SizedBox(height: 6),
        Text(
          '${widget.workout.duration} · ${widget.workout.exerciseCount} exercises',
          style: _body(),
        ),
        const SizedBox(height: 18),
        _summaryCard(),
        const SizedBox(height: 12),
        _exerciseCard(),
      ],
    ),
  );

  Widget _backButton() => Material(
    color: AppColors.primaryLight,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: () => Navigator.pop(context),
      child: const SizedBox(
        width: 40,
        height: 40,
        child: Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
      ),
    ),
  );

  Widget _summaryCard() => _panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('WORKOUT SUMMARY', style: _sectionTitle()),
        const SizedBox(height: 16),
        Row(
          children: [
            _summaryValue(widget.workout.duration, 'Duration'),
            const SizedBox(width: 52),
            _summaryValue('${widget.workout.exerciseCount}', 'Exercises'),
          ],
        ),
        const SizedBox(height: 12),
        Text('Equipment', style: _body()),
        const SizedBox(height: 2),
        Text(
          widget.workout.equipment,
          style: _body(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _exerciseCard() {
    if (widget.workout.exercises.isEmpty) {
      return _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EXERCISES', style: _sectionTitle()),
            const SizedBox(height: 18),
            Text('No exercises available', style: _title(18)),
            const SizedBox(height: 5),
            Text('This workout has not been configured yet.', style: _body()),
          ],
        ),
      );
    }
    return _panel(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EXERCISES', style: _sectionTitle()),
              const SizedBox(height: 4),
              ...widget.workout.exercises.asMap().entries.map(
                (entry) => _exerciseRow(entry.key + 1, entry.value),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/characters/penguin_bench_press.gif',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exerciseRow(int number, ExerciseItem exercise) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 7),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey.shade500)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${number.toString().padLeft(2, '0')}  ${exercise.name}',
          style: _body(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text('${exercise.sets} × ${exercise.reps}', style: _body()),
      ],
    ),
  );

  Widget _bottomAction() {
    final label = _isCompleted
        ? 'Workout Completed'
        : _isUpcoming
        ? widget.workout.id == 'today-push-day'
              ? 'Start Workout'
              : 'Upcoming Workout'
        : _canStart
        ? 'Start Workout'
        : 'No exercises available';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: AnimatedScale(
        scale: _pressed ? .98 : 1,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _canStart && !_starting ? _startWorkout : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: _starting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _panel({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: child,
  );

  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _summaryValue(String value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: _body(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      ),
      Text(label, style: _body()),
    ],
  );

  TextStyle _sectionTitle() => const TextStyle(
    color: AppColors.textPrimary,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
  );
  TextStyle _title(double size) => TextStyle(
    color: AppColors.textPrimary,
    fontSize: size,
    height: 1.15,
    fontWeight: FontWeight.w700,
  );
  TextStyle _body({
    double size = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textSecondary,
  }) => TextStyle(
    color: color,
    fontSize: size,
    height: 1.35,
    fontWeight: fontWeight,
  );
}
