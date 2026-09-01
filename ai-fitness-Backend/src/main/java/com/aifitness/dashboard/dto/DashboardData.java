package com.aifitness.dashboard.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardData {
    private String userName;
    private String greeting;
    private WorkoutSummary currentWorkout;
    private WeeklyCompletion weeklyCompletion;
    private Stats stats;
    private NutritionProgress nutritionProgress;
    private UpcomingMeal upcomingMeal;
    private String recommendationStatus;
    private boolean aiCoachAvailable;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WorkoutSummary {
        private String name;
        private String duration;
        private int exerciseCount;
        private String workoutDay;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WeeklyCompletion {
        private int completed;
        private int target;
        private double percentage;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Stats {
        private String caloriesBurned;
        private String activeMinutes;
        private String streak;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NutritionProgress {
        private int consumedCalories;
        private int targetCalories;
        private double percentage;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UpcomingMeal {
        private String name;
        private String details;
    }
}
