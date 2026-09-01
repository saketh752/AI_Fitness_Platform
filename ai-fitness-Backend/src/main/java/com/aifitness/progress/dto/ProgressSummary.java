package com.aifitness.progress.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ProgressSummary {
    private int totalWorkoutsCompleted;
    private int totalCaloriesBurned;
    private int totalActiveMinutes;
    private int currentStreak;
    private String caloriesBurnedDisplay;
    private String activeMinutesDisplay;
    private String streakDisplay;
}
