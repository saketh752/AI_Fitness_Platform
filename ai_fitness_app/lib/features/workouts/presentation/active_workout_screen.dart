import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import 'workout_plan_state.dart';
import 'workout_session.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({required this.workout, super.key});

  final WorkoutItem workout;

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen>
    with SingleTickerProviderStateMixin {
  late final WorkoutSession _session;
  bool _isNavigating = false;
  bool _isDialogShowing = false;
  int? _justCompletedSetIndex;

  @override
  void initState() {
    super.initState();
    _session = WorkoutSessionStore.forWorkout(widget.workout);
  }

  @override
  void dispose() {
    _session.cancelTimer();
    super.dispose();
  }

  void _completeSet() {
    if (_session.status != WorkoutSessionStatus.ready) return;
    final currentSet = _session.currentSetIndex;
    setState(() {
      _session.completeCurrentSet();
      _justCompletedSetIndex = currentSet;
      if (_session.isFinalSet) {
        _session.status = WorkoutSessionStatus.exerciseComplete;
      } else {
        _session.status = WorkoutSessionStatus.resting;
        _session.restRemaining = 90;
      }
    });

    if (_session.status == WorkoutSessionStatus.resting) {
      _startRestTimer();
    }
  }

  void _startRestTimer() {
    _session.cancelTimer();
    _session.restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_session.restRemaining <= 1) {
        _session.cancelTimer();
        _nextSet();
      } else {
        setState(() => _session.restRemaining--);
      }
    });
  }

  void _nextSet() {
    setState(() {
      _session.currentSetIndex++;
      _session.status = WorkoutSessionStatus.ready;
      _justCompletedSetIndex = null;
    });
  }

  void _skipRest() {
    _session.cancelTimer();
    _nextSet();
  }

  void _nextExercise() {
    if (_session.status != WorkoutSessionStatus.exerciseComplete) {
      return;
    }
    if (_session.isFinalExercise) {
      if (_isNavigating) return;
      setState(() => _isNavigating = true);
      _session.status = WorkoutSessionStatus.workoutComplete;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.workoutComplete,
        arguments: widget.workout,
      );
      return;
    }
    setState(() {
      _session.currentExerciseIndex++;
      _session.currentSetIndex = 0;
      _session.status = WorkoutSessionStatus.ready;
      _justCompletedSetIndex = null;
    });
  }

  void _analyzeForm() {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    Navigator.pushNamed(
      context,
      AppRoutes.formAnalysis,
      arguments: _session.exercise,
    ).then((_) {
      if (mounted) setState(() => _isNavigating = false);
    });
  }

  Future<void> _confirmLeave() async {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Workout?'),
        content: const Text('Your current progress will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    _isDialogShowing = false;
    if (leave == true && mounted) {
      _session.cancelTimer();
      Navigator.popUntil(
        context,
        (route) =>
            route.settings.name == AppRoutes.workoutOverview || route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _session.exercise;
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: _content(exercise),
                ),
              ),
              _actionArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(ExerciseItem exercise) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          _backButton(),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              widget.workout.name.split(':').first,
              style: _title(24),
            ),
          ),
          Text(
            '${_session.currentExerciseIndex + 1}/${widget.workout.exercises.length}',
            style: _body(
              fontSize: 18,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0.0,
            end: (_session.currentExerciseIndex + 1) /
                widget.workout.exercises.length,
          ),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          builder: (context, value, child) => LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          exercise.muscleGroup.isNotEmpty ? exercise.muscleGroup : 'Chest',
          style: _body(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(height: 10),
      Text(exercise.name, style: _title(25)),
      const SizedBox(height: 4),
      Text(
        '${exercise.sets} × ${exercise.reps}',
        style: _body(color: AppColors.textSecondary),
      ),
      const SizedBox(height: 14),
      Container(
        height: 200,
        width: double.infinity,
        alignment: Alignment.center,
        child: exercise.imageAsset.isNotEmpty
            ? Image.asset(
                exercise.imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: 72,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              )
            : Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Center(
                  child: Icon(
                    Icons.fitness_center_rounded,
                    size: 72,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
      ),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _analyzeForm,
          icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Analyze Form',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
        ),
      ),
      const SizedBox(height: 18),
      _setTable(),
    ],
  );

  Widget _backButton() => Material(
    color: AppColors.primaryLight,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: _confirmLeave,
      child: const SizedBox(
        width: 40,
        height: 40,
        child: Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
      ),
    ),
  );

  Widget _setTable() {
    final sets = _session.currentExerciseSets;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _tableHeader('SET', width: 44, align: TextAlign.left),
              Expanded(child: _tableHeader('WEIGHT', align: TextAlign.center)),
              _tableHeader('REPS', width: 44, align: TextAlign.right),
            ],
          ),
          const SizedBox(height: 4),
          for (var index = 0; index < sets.length; index++) ...[
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: sets[index].isCompleted
                        ? _animatedCheckmark(index == _justCompletedSetIndex)
                        : Text(
                            '${index + 1}',
                            textAlign: TextAlign.left,
                            style: _body(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () => _editWeight(index, sets[index].weightKg),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Text(
                            _formatWeight(sets[index].weightKg),
                            textAlign: TextAlign.center,
                            style: _body(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => _editReps(index, sets[index].reps),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            (index <= _session.currentSetIndex ||
                                    sets[index].isCompleted)
                                ? '${sets[index].reps}'
                                : '-',
                            textAlign: TextAlign.right,
                            style: _body(
                              fontSize: 16,
                              color: AppColors.textPrimary,
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
          ],
        ],
      ),
    );
  }

  Widget _animatedCheckmark(bool animate) {
    if (!animate) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.7, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: ((scale - 0.7) / 0.3).clamp(0.0, 1.0),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }

  String _formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return '${weight.toInt()} kg';
    }
    return '${weight.toStringAsFixed(1)} kg';
  }

  Widget _tableHeader(
    String text, {
    double? width,
    required TextAlign align,
  }) => SizedBox(
    width: width,
    child: Text(
      text,
      textAlign: align,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
  );

  Future<void> _editWeight(int setIndex, double currentWeight) async {
    final newWeight = await showDialog<double>(
      context: context,
      builder: (context) => _EditWeightDialog(
        setIndex: setIndex,
        initialWeight: currentWeight,
      ),
    );
    if (newWeight != null && mounted) {
      setState(() {
        _session.updateWeight(
          _session.currentExerciseIndex,
          setIndex,
          newWeight,
        );
      });
    }
  }

  Future<void> _editReps(int setIndex, int currentReps) async {
    final newReps = await showDialog<int>(
      context: context,
      builder: (context) => _EditRepsDialog(
        setIndex: setIndex,
        initialReps: currentReps,
      ),
    );
    if (newReps != null && mounted) {
      setState(() {
        _session.updateReps(
          _session.currentExerciseIndex,
          setIndex,
          newReps,
        );
      });
    }
  }

  Widget _actionArea() {
    if (_session.status == WorkoutSessionStatus.resting) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
        child: Column(
          children: [
            Text(
              'REST',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatRest(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Take a breather',
              style: _body(
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: _skipRest,
              child: const Text(
                'Skip Rest',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_session.status == WorkoutSessionStatus.exerciseComplete) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              builder: (context, value, child) => Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Exercise complete',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Great work!',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: _button(
                  _session.isFinalExercise ? 'Finish Workout →' : 'Next Exercise →',
                  _nextExercise,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      child: _button(
        'Complete Set',
        _completeSet,
        enabled: _session.status == WorkoutSessionStatus.ready,
      ),
    );
  }

  String _formatRest() {
    final minutes = _session.restRemaining ~/ 60;
    final seconds = _session.restRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _button(String text, VoidCallback onPressed, {bool enabled = true}) =>
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: Colors.grey.shade300,
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
      );

  TextStyle _title(double size) => TextStyle(
    color: AppColors.textPrimary,
    fontSize: size,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  TextStyle _body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textSecondary,
  }) => TextStyle(
    color: color,
    fontSize: fontSize,
    height: 1.35,
    fontWeight: fontWeight,
  );
}

class _EditWeightDialog extends StatefulWidget {
  const _EditWeightDialog({required this.setIndex, required this.initialWeight});

  final int setIndex;
  final double initialWeight;

  @override
  State<_EditWeightDialog> createState() => _EditWeightDialogState();
}

class _EditWeightDialogState extends State<_EditWeightDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final w = widget.initialWeight;
    _controller = TextEditingController(
      text: w == w.roundToDouble() ? '${w.toInt()}' : '$w',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_controller.text.trim());
    if (value == null || value <= 0) {
      setState(() => _errorText = 'Enter a valid weight (> 0)');
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Set ${widget.setIndex + 1} Weight'),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          suffixText: 'kg',
          hintText: 'e.g. 60',
          errorText: _errorText,
        ),
        onChanged: (_) {
          if (_errorText != null) setState(() => _errorText = null);
        },
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EditRepsDialog extends StatefulWidget {
  const _EditRepsDialog({required this.setIndex, required this.initialReps});

  final int setIndex;
  final int initialReps;

  @override
  State<_EditRepsDialog> createState() => _EditRepsDialogState();
}

class _EditRepsDialogState extends State<_EditRepsDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialReps}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value <= 0) {
      setState(() => _errorText = 'Enter valid reps (> 0)');
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Set ${widget.setIndex + 1} Reps'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          suffixText: 'reps',
          hintText: 'e.g. 10',
          errorText: _errorText,
        ),
        onChanged: (_) {
          if (_errorText != null) setState(() => _errorText = null);
        },
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
