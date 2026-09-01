package com.aifitness.user.dto;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileDto {
    private Long userId;
    private String email;
    private String fullName;
    private Integer age;
    private String gender;
    private BigDecimal heightCm;
    private BigDecimal currentWeightKg;
    private String fitnessGoal;
    private String activityLevel;
    private String fitnessExperience;
}

