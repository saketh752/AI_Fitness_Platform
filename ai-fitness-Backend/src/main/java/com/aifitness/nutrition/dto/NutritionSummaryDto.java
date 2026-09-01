package com.aifitness.nutrition.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NutritionSummaryDto {
    private Integer targetCalories;
    private Integer consumedCalories;
    private Integer remainingCalories;

    private Integer targetProteinGrams;
    private Integer consumedProteinGrams;

    private Integer targetCarbsGrams;
    private Integer consumedCarbsGrams;

    private Integer targetFatGrams;
    private Integer consumedFatGrams;

    private List<MealDto> todayMeals;
}

