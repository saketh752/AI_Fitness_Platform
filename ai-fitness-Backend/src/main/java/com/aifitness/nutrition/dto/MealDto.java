package com.aifitness.nutrition.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealDto {
    private Long id;
    private String mealType;
    private String name;
    private Integer calories;
    private Integer proteinGrams;
    private Integer carbsGrams;
    private Integer fatGrams;
    private LocalDateTime loggedAt;
}

