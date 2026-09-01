package com.aifitness.recommendation.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WorkoutLogRequest {
    private String workoutName;
    private Integer durationMinutes;
    private Integer caloriesBurned;
    private Integer exercisesCompleted;
}

