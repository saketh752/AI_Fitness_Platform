package com.aifitness.nutrition;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.aifitness.nutrition.dto.MealDto;
import com.aifitness.nutrition.dto.NutritionSummaryDto;
import com.aifitness.recommendation.Recommendation;
import com.aifitness.recommendation.RecommendationRepository;
import com.aifitness.user.User;
import com.aifitness.user.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class NutritionService {

    private final NutritionTargetRepository nutritionTargetRepository;
    private final RecommendationRepository recommendationRepository;
    private final UserRepository userRepository;
    private final MealLogRepository mealLogRepository;

    @Transactional
    public void createOrUpdateTargetFromPlan(Recommendation plan) {
        if (plan == null || plan.getNutritionTarget() == null) return;

        Long userId = plan.getUser().getId();
        LocalDate today = LocalDate.now();

        NutritionTarget target = nutritionTargetRepository.findByUserIdAndTargetDate(userId, today)
                .orElse(new NutritionTarget());

        target.setUser(plan.getUser());
        target.setTargetDate(today);

        String raw = plan.getNutritionTarget();
        target.setCaloriesTarget(extractInt(raw, "Calories:\\s*(\\d+)"));
        target.setProteinGramsTarget(extractInt(raw, "Protein:\\s*(\\d+)"));
        target.setCarbsGramsTarget(extractInt(raw, "Carbs:\\s*(\\d+)"));
        target.setFatGramsTarget(extractInt(raw, "Fat:\\s*(\\d+)"));

        nutritionTargetRepository.save(target);
        log.info("Saved NutritionTarget for user {} based on recommendation target: {}", userId, raw);
    }

    @Transactional(readOnly = true)
    public NutritionTarget getNutritionTarget(Long userId) {
        LocalDate today = LocalDate.now();
        return nutritionTargetRepository.findByUserIdAndTargetDate(userId, today)
                .orElseGet(() -> {
                    Recommendation latest = recommendationRepository.findTopByUserIdOrderByCreatedAtDesc(userId).orElse(null);
                    if (latest != null && latest.getNutritionTarget() != null) {
                        NutritionTarget target = new NutritionTarget();
                        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
                        target.setUser(user);
                        target.setTargetDate(today);
                        String raw = latest.getNutritionTarget();
                        target.setCaloriesTarget(extractInt(raw, "Calories:\\s*(\\d+)"));
                        target.setProteinGramsTarget(extractInt(raw, "Protein:\\s*(\\d+)"));
                        target.setCarbsGramsTarget(extractInt(raw, "Carbs:\\s*(\\d+)"));
                        target.setFatGramsTarget(extractInt(raw, "Fat:\\s*(\\d+)"));
                        return target;
                    }
                    NutritionTarget def = new NutritionTarget();
                    User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
                    def.setUser(user);
                    def.setTargetDate(today);
                    def.setCaloriesTarget(2200);
                    def.setProteinGramsTarget(140);
                    def.setCarbsGramsTarget(240);
                    def.setFatGramsTarget(65);
                    return def;
                });
    }

    @Transactional(readOnly = true)
    public NutritionSummaryDto getTodaySummary(Long userId) {
        NutritionTarget target = getNutritionTarget(userId);
        LocalDate today = LocalDate.now();
        List<MealLog> logs = mealLogRepository.findByUserIdAndLogDateOrderByLoggedAtDesc(userId, today);

        int consumedCalories = logs.stream().mapToInt(MealLog::getCalories).sum();
        int consumedProtein = logs.stream().mapToInt(m -> m.getProteinGrams() != null ? m.getProteinGrams() : 0).sum();
        int consumedCarbs = logs.stream().mapToInt(m -> m.getCarbsGrams() != null ? m.getCarbsGrams() : 0).sum();
        int consumedFat = logs.stream().mapToInt(m -> m.getFatGrams() != null ? m.getFatGrams() : 0).sum();

        int targetCal = target.getCaloriesTarget() != null ? target.getCaloriesTarget() : 2200;
        int remaining = Math.max(0, targetCal - consumedCalories);

        List<MealDto> mealDtos = logs.stream().map(this::mapToDto).collect(Collectors.toList());

        return NutritionSummaryDto.builder()
                .targetCalories(targetCal)
                .consumedCalories(consumedCalories)
                .remainingCalories(remaining)
                .targetProteinGrams(target.getProteinGramsTarget() != null ? target.getProteinGramsTarget() : 140)
                .consumedProteinGrams(consumedProtein)
                .targetCarbsGrams(target.getCarbsGramsTarget() != null ? target.getCarbsGramsTarget() : 240)
                .consumedCarbsGrams(consumedCarbs)
                .targetFatGrams(target.getFatGramsTarget() != null ? target.getFatGramsTarget() : 65)
                .consumedFatGrams(consumedFat)
                .todayMeals(mealDtos)
                .build();
    }

    @Transactional
    public MealDto logMeal(Long userId, MealDto request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        MealLog log = MealLog.builder()
                .user(user)
                .mealType(request.getMealType() != null ? request.getMealType().toUpperCase() : "SNACK")
                .name(request.getName() != null ? request.getName().trim() : "Custom Meal")
                .calories(request.getCalories() != null ? request.getCalories() : 0)
                .proteinGrams(request.getProteinGrams() != null ? request.getProteinGrams() : 0)
                .carbsGrams(request.getCarbsGrams() != null ? request.getCarbsGrams() : 0)
                .fatGrams(request.getFatGrams() != null ? request.getFatGrams() : 0)
                .logDate(LocalDate.now())
                .loggedAt(LocalDateTime.now())
                .build();

        MealLog saved = mealLogRepository.save(log);
        return mapToDto(saved);
    }

    @Transactional
    public void deleteMeal(Long userId, Long mealId) {
        mealLogRepository.deleteByIdAndUserId(mealId, userId);
    }

    @Transactional(readOnly = true)
    public List<MealDto> getTodayMeals(Long userId) {
        return mealLogRepository.findByUserIdAndLogDateOrderByLoggedAtDesc(userId, LocalDate.now())
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    private MealDto mapToDto(MealLog log) {
        return MealDto.builder()
                .id(log.getId())
                .mealType(log.getMealType())
                .name(log.getName())
                .calories(log.getCalories())
                .proteinGrams(log.getProteinGrams())
                .carbsGrams(log.getCarbsGrams())
                .fatGrams(log.getFatGrams())
                .loggedAt(log.getLoggedAt())
                .build();
    }

    private Integer extractInt(String source, String regex) {
        try {
            Pattern pattern = Pattern.compile(regex, Pattern.CASE_INSENSITIVE);
            Matcher matcher = pattern.matcher(source);
            if (matcher.find()) {
                return Integer.parseInt(matcher.group(1));
            }
        } catch (Exception e) {
            log.warn("Failed to extract value from '{}' with regex '{}'", source, regex);
        }
        return 0;
    }
}
