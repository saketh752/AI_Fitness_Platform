package com.aifitness.onboarding;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.aifitness.health.assessment.UserCondition;
import com.aifitness.health.assessment.UserConditionRepository;
import com.aifitness.health.condition.Condition;
import com.aifitness.health.condition.ConditionRepository;
import com.aifitness.health.risk.RiskEngine;
import com.aifitness.nutrition.NutritionService;
import com.aifitness.onboarding.dto.OnboardingRequest;
import com.aifitness.onboarding.dto.OnboardingResponse;
import com.aifitness.recommendation.Recommendation;
import com.aifitness.recommendation.RecommendationService;
import com.aifitness.user.*;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OnboardingService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final UserEquipmentRepository userEquipmentRepository;
    private final EquipmentRepository equipmentRepository;
    private final UserFoodRepository userFoodRepository;
    private final UserConditionRepository userConditionRepository;
    private final ConditionRepository conditionRepository;
    private final UserGoalRepository userGoalRepository;
    private final UserConstraintRepository userConstraintRepository;
    private final FitnessCalculationRepository fitnessCalculationRepository;
    private final RiskEngine riskEngine;
    private final RecommendationService recommendationService;
    private final NutritionService nutritionService;

    @Transactional
    public OnboardingResponse completeOnboarding(Long userId, OnboardingRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // 1. Save User Goal
        String mappedGoalType = mapGoalType(request.getFitnessGoal());
        java.util.List<UserGoal> activeGoals = userGoalRepository.findByUserIdAndStatus(userId, "ACTIVE");
        UserGoal goal;
        if (!activeGoals.isEmpty()) {
            goal = activeGoals.get(0);
        } else {
            goal = new UserGoal();
            goal.setUser(user);
            goal.setStatus("ACTIVE");
            goal.setStartedAt(java.time.LocalDateTime.now());
        }
        goal.setGoalType(mappedGoalType);
        userGoalRepository.save(goal);

        // 2. Save User Profile
        UserProfile profile = userProfileRepository.findByUserId(userId)
                .orElse(new UserProfile());

        profile.setUser(user);
        profile.setFullName(request.getName());
        if (request.getAge() != null) {
            profile.setDateOfBirth(java.time.LocalDate.now().minusYears(request.getAge()));
        }
        profile.setGender(request.getGender());
        profile.setHeightCm(request.getHeightCm() != null ? java.math.BigDecimal.valueOf(request.getHeightCm()) : null);
        profile.setCurrentWeightKg(request.getWeightKg() != null ? java.math.BigDecimal.valueOf(request.getWeightKg()) : null);
        profile.setFitnessExperience(request.getFitnessLevel());
        userProfileRepository.save(profile);

        // 3. Save Equipment
        userEquipmentRepository.deleteAllByUserId(userId);
        if (request.getEquipment() != null) {
            for (String eq : request.getEquipment()) {
                String trimmed = eq.trim();
                if (trimmed.isEmpty()) continue;
                Equipment equipment = equipmentRepository.findByName(trimmed)
                        .orElseGet(() -> {
                            Equipment newEq = new Equipment();
                            newEq.setName(trimmed);
                            newEq.setCategory("GENERAL");
                            return equipmentRepository.save(newEq);
                        });
                UserEquipment ue = new UserEquipment();
                ue.setUser(user);
                ue.setEquipment(equipment);
                userEquipmentRepository.save(ue);
            }
        }

        // 4. Save Foods
        userFoodRepository.deleteAllByUserId(userId);
        if (request.getFoods() != null) {
            for (String f : request.getFoods()) {
                UserFood food = new UserFood();
                food.setUser(user);
                food.setFoodCode(f);
                if ("OTHER".equalsIgnoreCase(f) || "OtherFood".equalsIgnoreCase(f)) {
                    food.setOtherFoodDetail(request.getOtherFood());
                }
                userFoodRepository.save(food);
            }
        }

        // 5. Save Constraints (Budget, Preferred Duration)
        userConstraintRepository.deleteAllByUserId(userId);
        if (request.getBudget() != null && !request.getBudget().isBlank()) {
            UserConstraint uc = new UserConstraint();
            uc.setUser(user);
            uc.setConstraintType("FOOD_BUDGET");
            uc.setConstraintValue(request.getCustomBudget() != null ? request.getCustomBudget() : request.getBudget());
            userConstraintRepository.save(uc);
        }
        if (request.getPreferredDuration() != null && !request.getPreferredDuration().isBlank()) {
            UserConstraint uc = new UserConstraint();
            uc.setUser(user);
            uc.setConstraintType("TRAINING_TIME");
            uc.setConstraintValue(request.getCustomDuration() != null ? request.getCustomDuration() : request.getPreferredDuration());
            userConstraintRepository.save(uc);
        }

        // 6. Save Fitness Calculations (BMI, BMR, TDEE)
        if (request.getHeightCm() != null && request.getWeightKg() != null) {
            double hM = request.getHeightCm() / 100.0;
            double wKg = request.getWeightKg();
            double bmiVal = wKg / (hM * hM);
            int age = request.getAge() != null ? request.getAge() : 25;
            
            // Mifflin-St Jeor Equation
            double bmrVal = "FEMALE".equalsIgnoreCase(request.getGender())
                    ? (10 * wKg) + (6.25 * request.getHeightCm()) - (5 * age) - 161
                    : (10 * wKg) + (6.25 * request.getHeightCm()) - (5 * age) + 5;
            
            double tdeeVal = bmrVal * 1.375; // Moderate active baseline
            double calTarget = "WEIGHT_LOSS".equals(mappedGoalType) ? tdeeVal - 500 :
                               ("WEIGHT_GAIN".equals(mappedGoalType) || "MUSCLE_GAIN".equals(mappedGoalType)) ? tdeeVal + 300 : tdeeVal;
            
            double proteinG = wKg * 1.8;
            double fatG = (calTarget * 0.25) / 9.0;
            double carbsG = (calTarget - (proteinG * 4.0) - (fatG * 9.0)) / 4.0;

            FitnessCalculation calc = new FitnessCalculation();
            calc.setUser(user);
            calc.setBmi(java.math.BigDecimal.valueOf(bmiVal).setScale(2, java.math.RoundingMode.HALF_UP));
            calc.setBmr(java.math.BigDecimal.valueOf(bmrVal).setScale(2, java.math.RoundingMode.HALF_UP));
            calc.setTdee(java.math.BigDecimal.valueOf(tdeeVal).setScale(2, java.math.RoundingMode.HALF_UP));
            calc.setCalorieTarget(java.math.BigDecimal.valueOf(calTarget).setScale(2, java.math.RoundingMode.HALF_UP));
            calc.setProteinTargetG(java.math.BigDecimal.valueOf(proteinG).setScale(2, java.math.RoundingMode.HALF_UP));
            calc.setFatTargetG(java.math.BigDecimal.valueOf(fatG).setScale(2, java.math.RoundingMode.HALF_UP));
            calc.setCarbsTargetG(java.math.BigDecimal.valueOf(carbsG).setScale(2, java.math.RoundingMode.HALF_UP));
            calc.setCalculatedAt(java.time.LocalDateTime.now());
            fitnessCalculationRepository.save(calc);
        }

        // 7. Save Health Conditions
        userConditionRepository.deleteAllByUserId(userId);
        if (request.getHealthConditions() != null && !request.getHealthConditions().isBlank()) {
            String[] conditions = request.getHealthConditions().split(",");
            for (String condName : conditions) {
                String trimmedName = condName.trim();
                if (trimmedName.isEmpty()) continue;

                String code = trimmedName.toUpperCase().replace(" ", "_");
                Condition condition = conditionRepository.findByCode(code)
                        .orElseGet(() -> {
                            Condition newCond = new Condition();
                            newCond.setCode(code);
                            newCond.setName(trimmedName);
                            newCond.setDefaultRiskLevel("LOW");
                            return conditionRepository.save(newCond);
                        });

                UserCondition uc = new UserCondition();
                uc.setUser(user);
                uc.setCondition(condition);
                uc.setSeverity("MODERATE"); // default for now
                userConditionRepository.save(uc);
            }
        }

        // 8. Call Health/Risk Engine
        java.util.List<UserCondition> userConditions = userConditionRepository.findAllByUserId(userId);
        RiskEngine.RiskAssessment assessment = riskEngine.assessRisk(userConditions);

        // 9. Trigger Plan Generation
        Recommendation plan = recommendationService.generatePlan(userId, assessment.riskLevel().name(), assessment.status().name());

        // 10. Save Nutrition Target from Plan
        nutritionService.createOrUpdateTargetFromPlan(plan);

        return OnboardingResponse.builder()
                .status(assessment.status().name())
                .riskLevel(assessment.riskLevel().name())
                .recommendationId(plan.getId())
                .message("Profile saved successfully.")
                .build();
    }

    private String mapGoalType(String rawGoal) {
        if (rawGoal == null) {
            throw new IllegalArgumentException("Fitness goal cannot be empty");
        }
        String normalized = rawGoal.trim().toLowerCase();
        switch (normalized) {
            case "weight loss":
            case "lose weight":
            case "weight_loss":
                return "WEIGHT_LOSS";
            case "weight gain":
            case "gain weight":
            case "weight_gain":
                return "WEIGHT_GAIN";
            case "muscle gain":
            case "build muscle":
            case "muscle building":
            case "muscle_gain":
                return "MUSCLE_GAIN";
            case "strength":
            case "build strength":
                return "STRENGTH";
            case "general fitness":
            case "fitness":
            case "get fit":
            case "general_fitness":
                return "GENERAL_FITNESS";
            default:
                String upper = rawGoal.toUpperCase();
                if (upper.equals("WEIGHT_LOSS") || upper.equals("WEIGHT_GAIN") || upper.equals("MUSCLE_GAIN") || upper.equals("STRENGTH") || upper.equals("GENERAL_FITNESS")) {
                    return upper;
                }
                throw new IllegalArgumentException("Unsupported fitness goal: " + rawGoal);
        }
    }
}
