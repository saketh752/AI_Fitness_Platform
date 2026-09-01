package com.aifitness.dashboard;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.aifitness.dashboard.dto.DashboardData;
import com.aifitness.nutrition.NutritionService;
import com.aifitness.nutrition.dto.NutritionSummaryDto;
import com.aifitness.progress.ProgressService;
import com.aifitness.progress.dto.ProgressSummary;
import com.aifitness.recommendation.Recommendation;
import com.aifitness.recommendation.RecommendationRepository;
import com.aifitness.user.User;
import com.aifitness.user.UserProfile;
import com.aifitness.user.UserProfileRepository;

@ExtendWith(MockitoExtension.class)
class DashboardServiceTest {

    @Mock
    private UserProfileRepository userProfileRepository;

    @Mock
    private RecommendationRepository recommendationRepository;

    @Mock
    private ProgressService progressService;

    @Mock
    private NutritionService nutritionService;

    @InjectMocks
    private DashboardService dashboardService;

    private UserProfile testProfile;
    private Recommendation testPlan;
    private ProgressSummary testSummary;
    private NutritionSummaryDto testNutrition;

    @BeforeEach
    void setUp() {
        User user = new User();
        user.setId(1L);

        testProfile = new UserProfile();
        testProfile.setUser(user);
        testProfile.setFullName("Arjun Kumar");
        testProfile.setCurrentWeightKg(new BigDecimal("70.0"));

        testPlan = new Recommendation();
        testPlan.setUser(user);
        testPlan.setPlanName("Full Body Hypertrophy");
        testPlan.setDaysPerWeek(4);
        testPlan.setMinutesPerSession(45);
        testPlan.setStatus("ACTIVE");

        testSummary = ProgressSummary.builder()
                .totalWorkoutsCompleted(3)
                .caloriesBurnedDisplay("450 kcal")
                .activeMinutesDisplay("60 min")
                .streakDisplay("4 Days")
                .build();

        testNutrition = NutritionSummaryDto.builder()
                .targetCalories(2200)
                .consumedCalories(800)
                .remainingCalories(1400)
                .build();
    }

    @Test
    void getDashboard_CombinesAllModules() {
        when(userProfileRepository.findByUserId(1L)).thenReturn(Optional.of(testProfile));
        when(recommendationRepository.findTopByUserIdOrderByCreatedAtDesc(1L)).thenReturn(Optional.of(testPlan));
        when(progressService.getSummary(1L)).thenReturn(testSummary);
        when(nutritionService.getTodaySummary(1L)).thenReturn(testNutrition);

        DashboardData data = dashboardService.getDashboard(1L);

        assertNotNull(data);
        assertEquals("Arjun", data.getUserName());
        assertEquals("Full Body Hypertrophy", data.getCurrentWorkout().getName());
        assertEquals(3, data.getWeeklyCompletion().getCompleted());
        assertEquals(4, data.getWeeklyCompletion().getTarget());
        assertEquals(800, data.getNutritionProgress().getConsumedCalories());
        assertEquals(2200, data.getNutritionProgress().getTargetCalories());
        assertEquals("4 Days", data.getStats().getStreak());
    }
}

