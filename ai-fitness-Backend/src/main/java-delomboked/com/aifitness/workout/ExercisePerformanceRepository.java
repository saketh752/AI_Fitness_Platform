package com.aifitness.workout;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ExercisePerformanceRepository extends JpaRepository<ExercisePerformance, Long> {
    List<ExercisePerformance> findByWorkoutSessionId(Long workoutSessionId);
    List<ExercisePerformance> findByWorkoutSessionIdOrderByExerciseOrderAsc(Long workoutSessionId);
}

