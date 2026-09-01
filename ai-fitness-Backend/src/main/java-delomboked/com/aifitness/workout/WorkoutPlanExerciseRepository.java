package com.aifitness.workout;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WorkoutPlanExerciseRepository extends JpaRepository<WorkoutPlanExercise, Long> {
    List<WorkoutPlanExercise> findByWorkoutPlanId(Long workoutPlanId);
    List<WorkoutPlanExercise> findByWorkoutPlanIdAndDayNumber(Long workoutPlanId, Integer dayNumber);
}

