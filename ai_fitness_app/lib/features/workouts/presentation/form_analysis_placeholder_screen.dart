import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import 'workout_plan_state.dart';

class FormAnalysisPlaceholderScreen extends StatelessWidget {
  const FormAnalysisPlaceholderScreen({required this.exercise, super.key});

  final ExerciseItem exercise;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('Form Analysis')),
    body: Center(
      child: Text(
        '${exercise.name}\nForm analysis is coming next.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
