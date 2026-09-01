package com.aifitness.onboarding.dto;

import java.util.List;

import lombok.Data;

@Data
public class OnboardingRequest {
    private String name;
    private Integer age;
    private String gender;
    private Integer heightCm;
    private Integer weightKg;
    private String fitnessGoal;
    private String fitnessLevel;
    private List<String> equipment;
    private List<String> foods;
    private String otherFood;
    private String budget;
    private String customBudget;
    private String workoutFrequency;
    private String preferredDuration;
    private String customDuration;
    private String healthConditions;
}
