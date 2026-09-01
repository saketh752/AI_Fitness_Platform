import 'dart:async';

import 'workout_plan_state.dart';

enum WorkoutSessionStatus { ready, resting, exerciseComplete, workoutComplete }

class SetRecord {
  SetRecord({
    required this.weightKg,
    required this.reps,
    this.isCompleted = false,
  });

  double weightKg;
  int reps;
  bool isCompleted;
}

class WorkoutSession {
  WorkoutSession(this.workout)
    : exerciseSets = List.generate(
        workout.exercises.length,
        (i) {
          final ex = workout.exercises[i];
          final count = ex.setCount > 0 ? ex.setCount : 3;
          return List.generate(
            count,
            (_) => SetRecord(
              weightKg: ex.defaultWeightKg,
              reps: ex.defaultReps,
            ),
          );
        },
      );

  final WorkoutItem workout;
  int currentExerciseIndex = 0;
  int currentSetIndex = 0;
  final List<List<SetRecord>> exerciseSets;
  WorkoutSessionStatus status = WorkoutSessionStatus.ready;
  int restRemaining = 90;
  Timer? restTimer;

  List<List<bool>> get completedSets =>
      exerciseSets.map((sets) => sets.map((s) => s.isCompleted).toList()).toList();

  ExerciseItem get exercise => workout.exercises[currentExerciseIndex];

  List<SetRecord> get currentExerciseSets => exerciseSets[currentExerciseIndex];

  bool get isFinalSet =>
      currentSetIndex >= exerciseSets[currentExerciseIndex].length - 1;

  bool get isFinalExercise =>
      currentExerciseIndex >= workout.exercises.length - 1;

  void completeCurrentSet() {
    if (currentExerciseIndex < exerciseSets.length &&
        currentSetIndex < exerciseSets[currentExerciseIndex].length) {
      exerciseSets[currentExerciseIndex][currentSetIndex].isCompleted = true;
    }
  }

  void updateWeight(int exerciseIndex, int setIndex, double weightKg) {
    if (exerciseIndex < exerciseSets.length &&
        setIndex < exerciseSets[exerciseIndex].length) {
      exerciseSets[exerciseIndex][setIndex].weightKg = weightKg;
    }
  }

  void updateReps(int exerciseIndex, int setIndex, int reps) {
    if (exerciseIndex < exerciseSets.length &&
        setIndex < exerciseSets[exerciseIndex].length) {
      exerciseSets[exerciseIndex][setIndex].reps = reps;
    }
  }

  void cancelTimer() {
    restTimer?.cancel();
    restTimer = null;
  }

  void dispose() {
    cancelTimer();
  }
}

class WorkoutSessionStore {
  WorkoutSessionStore._();

  static final Map<String, WorkoutSession> _sessions = {};

  static WorkoutSession forWorkout(WorkoutItem workout) =>
      _sessions.putIfAbsent(workout.id, () => WorkoutSession(workout));

  static void clear(String workoutId) {
    _sessions.remove(workoutId)?.dispose();
  }

  static void clearAll() {
    for (final session in _sessions.values) {
      session.dispose();
    }
    _sessions.clear();
  }
}
