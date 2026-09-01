package com.aifitness.nutrition;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.aifitness.nutrition.dto.MealDto;
import com.aifitness.nutrition.dto.NutritionSummaryDto;
import com.aifitness.recommendation.RecommendationRepository;
import com.aifitness.user.User;
import com.aifitness.user.UserRepository;

@ExtendWith(MockitoExtension.class)
class NutritionServiceTest {

    @Mock
    private NutritionTargetRepository nutritionTargetRepository;

    @Mock
    private RecommendationRepository recommendationRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private MealLogRepository mealLogRepository;

    @InjectMocks
    private NutritionService nutritionService;

    private User testUser;
    private NutritionTarget testTarget;
    private MealLog testMeal;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);

        testTarget = new NutritionTarget();
        testTarget.setUser(testUser);
        testTarget.setCaloriesTarget(2200);
        testTarget.setProteinGramsTarget(140);
        testTarget.setCarbsGramsTarget(240);
        testTarget.setFatGramsTarget(65);

        testMeal = MealLog.builder()
                .id(1L)
                .user(testUser)
                .name("Oatmeal & Banana")
                .mealType("BREAKFAST")
                .calories(450)
                .proteinGrams(20)
                .carbsGrams(60)
                .fatGrams(10)
                .logDate(LocalDate.now())
                .loggedAt(LocalDateTime.now())
                .build();
    }

    @Test
    void getTodaySummary_CalculatesConsumedAndRemaining() {
        LocalDate today = LocalDate.now();
        when(nutritionTargetRepository.findByUserIdAndTargetDate(1L, today)).thenReturn(Optional.of(testTarget));
        when(mealLogRepository.findByUserIdAndLogDateOrderByLoggedAtDesc(1L, today)).thenReturn(List.of(testMeal));

        NutritionSummaryDto summary = nutritionService.getTodaySummary(1L);

        assertNotNull(summary);
        assertEquals(2200, summary.getTargetCalories());
        assertEquals(450, summary.getConsumedCalories());
        assertEquals(1750, summary.getRemainingCalories());
        assertEquals(140, summary.getTargetProteinGrams());
        assertEquals(20, summary.getConsumedProteinGrams());
        assertEquals(1, summary.getTodayMeals().size());
    }

    @Test
    void logMeal_SavesMealLog() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(mealLogRepository.save(any(MealLog.class))).thenReturn(testMeal);

        MealDto request = MealDto.builder()
                .name("Grilled Chicken Bowl")
                .mealType("LUNCH")
                .calories(550)
                .proteinGrams(45)
                .carbsGrams(50)
                .fatGrams(15)
                .build();

        MealDto result = nutritionService.logMeal(1L, request);

        assertNotNull(result);
        verify(mealLogRepository).save(any(MealLog.class));
    }

    @Test
    void deleteMeal_CallsRepositoryDelete() {
        nutritionService.deleteMeal(1L, 10L);
        verify(mealLogRepository).deleteByIdAndUserId(10L, 1L);
    }
}

