import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../workouts/presentation/workout_plan_state.dart';
import 'dashboard_data.dart';

class DashboardDestinationPlaceholder extends StatelessWidget {
  const DashboardDestinationPlaceholder({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          '$title\nComing soon in the next phase.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class WorkoutDetailsPlaceholder extends StatelessWidget {
  const WorkoutDetailsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Today's Workout")),
      body: Center(
        child: Text(
          '${DashboardData.currentWorkout}\nComing next in the Workout phase',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class ActiveWorkoutPlaceholder extends StatelessWidget {
  const ActiveWorkoutPlaceholder({required this.workout, super.key});

  final WorkoutItem workout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Active Workout')),
      body: Center(
        child: Text(
          '${workout.name}\nExercise 1 · Set 1\nActive Workout coming next',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
