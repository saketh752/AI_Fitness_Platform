enum WorkoutStatus { completed, upcoming, rest }

class ExerciseItem {
  const ExerciseItem({
    required this.name,
    required this.sets,
    required this.reps,
    this.imageAsset = '',
    this.muscleGroup = '',
    this.equipment = '',
    this.defaultWeightKg = 60.0,
    this.defaultReps = 10,
    this.setCount = 3,
  });

  final String name;
  final String sets;
  final String reps;
  final String imageAsset;
  final String muscleGroup;
  final String equipment;
  final double defaultWeightKg;
  final int defaultReps;
  final int setCount;
}

class WorkoutItem {
  const WorkoutItem({
    required this.id,
    required this.name,
    required this.detail,
    required this.status,
    required this.duration,
    required this.exerciseCount,
    required this.equipment,
    this.dayNumber = 1,
    this.exercises = const [],
  });

  final String id;
  final String name;
  final String detail;
  final WorkoutStatus status;
  final String duration;
  final int exerciseCount;
  final String equipment;
  final int dayNumber;
  final List<ExerciseItem> exercises;
}

class WorkoutPlanState {
  WorkoutPlanState._();

  static bool pushWorkoutCompleted = false;

  static const goal = 'Build Muscle';
  static const week = 'Week 1 of 12';
  static int get completedWorkouts => pushWorkoutCompleted ? 4 : 3;
  static const targetWorkouts = 4;
  static const todayName = 'Push Day: Chest & Triceps';
  static const todayDay = 'Day 3 of 4';
  static const todayDetails = '45 mins · 6 exercises · Dumbbells & Bench';

  static List<WorkoutItem> get schedule => [
    WorkoutItem(
      id: 'push-day',
      name: 'Push Day: Chest & Triceps',
      detail: pushWorkoutCompleted ? 'Completed' : 'Upcoming',
      status: pushWorkoutCompleted
          ? WorkoutStatus.completed
          : WorkoutStatus.upcoming,
      duration: '45 min',
      exerciseCount: 6,
      equipment: 'Dumbbells & Bench',
      dayNumber: 3,
      exercises: _pushExercises,
    ),
    WorkoutItem(
      id: 'pull-day',
      name: 'Pull Day: Back & Biceps',
      detail: 'Upcoming',
      status: WorkoutStatus.upcoming,
      duration: '45 min',
      exerciseCount: 6,
      equipment: 'Dumbbells & Bench',
    ),
    WorkoutItem(
      id: 'leg-day',
      name: 'Leg Day: Legs & Core',
      detail: 'Upcoming',
      status: WorkoutStatus.upcoming,
      duration: '50 min',
      exerciseCount: 7,
      equipment: 'Dumbbells & Bench',
    ),
    WorkoutItem(
      id: 'rest-day',
      name: 'Rest Day: Recovery',
      detail: 'Rest',
      status: WorkoutStatus.rest,
      duration: '0 min',
      exerciseCount: 0,
      equipment: 'None',
    ),
  ];

  static const _pushExercises = [
    ExerciseItem(
      name: 'Barbell Bench Press',
      sets: '3 sets',
      reps: '8–10 reps',
      imageAsset: 'assets/images/exercises/barbell_bench_press.gif',
      muscleGroup: 'Chest',
      equipment: 'Barbell & Bench',
      defaultWeightKg: 60.0,
      defaultReps: 10,
      setCount: 3,
    ),
    ExerciseItem(
      name: 'Incline Dumbbell Press',
      sets: '3 sets',
      reps: '10–12 reps',
      imageAsset: 'assets/images/exercises/incline_dumbbell_press.gif',
      muscleGroup: 'Chest',
      equipment: 'Dumbbells & Incline Bench',
      defaultWeightKg: 20.0,
      defaultReps: 10,
      setCount: 3,
    ),
    ExerciseItem(
      name: 'Chest Fly',
      sets: '3 sets',
      reps: '12 reps',
      imageAsset: 'assets/images/exercises/chest_fly.gif',
      muscleGroup: 'Chest',
      equipment: 'Dumbbells',
      defaultWeightKg: 20.0,
      defaultReps: 12,
      setCount: 3,
    ),
    ExerciseItem(
      name: 'Dumbbell Shoulder Press',
      sets: '3 sets',
      reps: '10 reps',
      imageAsset: 'assets/images/exercises/dumbbell_shoulder_press.gif',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbells',
      defaultWeightKg: 20.0,
      defaultReps: 10,
      setCount: 3,
    ),
    ExerciseItem(
      name: 'Tricep Pushdown',
      sets: '3 sets',
      reps: '12 reps',
      imageAsset: 'assets/images/exercises/tricep_pushdown.gif',
      muscleGroup: 'Triceps',
      equipment: 'Cable Machine',
      defaultWeightKg: 25.0,
      defaultReps: 12,
      setCount: 3,
    ),
    ExerciseItem(
      name: 'Tricep Extension',
      sets: '3 sets',
      reps: '12 reps',
      imageAsset: 'assets/images/exercises/tricep_extension.gif',
      muscleGroup: 'Triceps',
      equipment: 'Dumbbells',
      defaultWeightKg: 15.0,
      defaultReps: 12,
      setCount: 3,
    ),
  ];

  static WorkoutItem get today => WorkoutItem(
    id: 'today-push-day',
    name: 'Push Day: Chest & Triceps',
    detail: pushWorkoutCompleted ? 'Completed' : 'Today',
    status: pushWorkoutCompleted
        ? WorkoutStatus.completed
        : WorkoutStatus.upcoming,
    duration: '45 min',
    exerciseCount: 6,
    equipment: 'Dumbbells & Bench',
    dayNumber: 3,
    exercises: _pushExercises,
  );

  static double get completion => completedWorkouts / targetWorkouts;

  static void markTodayCompleted() {
    pushWorkoutCompleted = true;
  }

  static void reset() {
    pushWorkoutCompleted = false;
  }
}
