package com.aifitness.recommendation.dto;

import java.util.List;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PlanResponse {
    private Long id;
    private String status;
    private String riskLevel;
    private String planName;
    private Integer weeks;
    private Integer daysPerWeek;
    private String nutritionTarget;
    private List<PlanExercise> exercises;

    @Data
    @Builder
    public static class PlanExercise {
        private String name;
        private Integer dayNumber;
        private Integer orderIndex;
        private Integer sets;
        private String reps;
    }
}
