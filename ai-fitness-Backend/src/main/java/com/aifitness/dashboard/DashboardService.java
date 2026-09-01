package com.aifitness.dashboard;

import java.time.LocalTime;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.aifitness.dashboard.dto.DashboardData;
import com.aifitness.nutrition.NutritionService;
import com.aifitness.nutrition.dto.NutritionSummaryDto;
import com.aifitness.progress.ProgressService;
import com.aifitness.progress.dto.ProgressSummary;
import com.aifitness.recommendation.Recommendation;
import com.aifitness.recommendation.RecommendationRepository;
import com.aifitness.user.UserProfile;
import com.aifitness.user.UserProfileRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final UserProfileRepository userProfileRepository;
    private final RecommendationRepository recommendationRepository;
    private final ProgressService progressService;
    private final NutritionService nutritionService;

    @Transactional(readOnly = true)
    public DashboardData getDashboard(Long userId) {
        UserProfile profile = userProfileRepository.findByUserId(userId).orElse(null);
        String name = profile != null ? (profile.getFullName() != null && !profile.getFullName().isBlank() ? profile.getFullName().split(" ")[0] : "Athlete") : "Athlete";
        String greeting = getGreeting();

        // Get recommendation status
        Recommendation rec = recommendationRepository.findTopByUserIdOrderByCreatedAtDesc(userId).orElse(null);
        String recStatus = rec != null ? rec.getStatus() : "ACTIVE";
        String workoutName = rec != null && rec.getPlanName() != null ? rec.getPlanName() : "Full Body Strength";
        int daysPerWeek = rec != null && rec.getDaysPerWeek() != null ? rec.getDaysPerWeek() : 4;
        int durationMin = rec != null && rec.getMinutesPerSession() != null ? rec.getMinutesPerSession() : 45;

        // Get progress summary
        ProgressSummary summary = progressService.getSummary(userId);

        // Compute weekly completion
        int target = daysPerWeek;
        int completed = Math.min(target, summary.getTotalWorkoutsCompleted() % 7);
        double pct = target > 0 ? (double) completed / target : 0.0;

        // Get nutrition summary
        NutritionSummaryDto nutrition = nutritionService.getTodaySummary(userId);
        double nutritionPct = nutrition.getTargetCalories() > 0 ? (double) nutrition.getConsumedCalories() / nutrition.getTargetCalories() : 0.0;

        String nextMealName = "Healthy Balanced Meal";
        if (nutrition.getTodayMeals() != null && !nutrition.getTodayMeals().isEmpty()) {
            nextMealName = nutrition.getTodayMeals().get(0).getName();
        }

        return DashboardData.builder()
                .userName(name)
                .greeting(greeting)
                .currentWorkout(DashboardData.WorkoutSummary.builder()
                        .name(workoutName)
                        .duration(durationMin + " min")
                        .exerciseCount(6)
                        .workoutDay("Day " + Math.max(1, completed + 1) + " of " + target)
                        .build())
                .weeklyCompletion(DashboardData.WeeklyCompletion.builder()
                        .completed(completed)
                        .target(target)
                        .percentage(pct)
                        .build())
                .stats(DashboardData.Stats.builder()
                        .caloriesBurned(summary.getCaloriesBurnedDisplay())
                        .activeMinutes(summary.getActiveMinutesDisplay())
                        .streak(summary.getStreakDisplay())
                        .build())
                .nutritionProgress(DashboardData.NutritionProgress.builder()
                        .consumedCalories(nutrition.getConsumedCalories())
                        .targetCalories(nutrition.getTargetCalories())
                        .percentage(Math.min(1.0, nutritionPct))
                        .build())
                .upcomingMeal(DashboardData.UpcomingMeal.builder()
                        .name(nextMealName)
                        .details(nutrition.getConsumedCalories() + " / " + nutrition.getTargetCalories() + " kcal")
                        .build())
                .recommendationStatus(recStatus)
                .aiCoachAvailable(true)
                .build();
    }

    private String getGreeting() {
        int hour = LocalTime.now().getHour();
        if (hour < 12) return "Good Morning";
        if (hour < 17) return "Good Afternoon";
        return "Good Evening";
    }
}
