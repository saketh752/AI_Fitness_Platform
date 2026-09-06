class ProgressData {
  const ProgressData({
    required this.currentStreakDays,
    required this.bestStreakDays,
    required this.weeklyCompletedWorkouts,
    required this.weeklyWorkoutTarget,
    required this.totalCompletedWorkouts,
    required this.activeMinutes,
    required this.caloriesBurned,
    required this.totalWorkoutMinutes,
    required this.goal,
    required this.goalProgressPercent,
  });

  final int currentStreakDays;
  final int bestStreakDays;
  final int weeklyCompletedWorkouts;
  final int weeklyWorkoutTarget;
  final int totalCompletedWorkouts;
  final int activeMinutes;
  final int caloriesBurned;
  final int totalWorkoutMinutes;
  final String goal;
  final int goalProgressPercent;

  double get weeklyProgress {
    if (weeklyWorkoutTarget <= 0) {
      return 0;
    }

    return (weeklyCompletedWorkouts / weeklyWorkoutTarget)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  double get goalProgress {
    return (goalProgressPercent / 100).clamp(0.0, 1.0).toDouble();
  }

  String get totalTimeLabel {
    final hours = totalWorkoutMinutes ~/ 60;
    final minutes = totalWorkoutMinutes % 60;

    if (hours <= 0) {
      return '${minutes}m';
    }

    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  static const mock = ProgressData(
    currentStreakDays: 5,
    bestStreakDays: 12,
    weeklyCompletedWorkouts: 3,
    weeklyWorkoutTarget: 4,
    totalCompletedWorkouts: 12,
    activeMinutes: 45,
    caloriesBurned: 340,
    totalWorkoutMinutes: 560,
    goal: 'Build Muscle',
    goalProgressPercent: 75,
  );
}
