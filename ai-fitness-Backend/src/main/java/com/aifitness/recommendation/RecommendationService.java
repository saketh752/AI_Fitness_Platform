package com.aifitness.recommendation;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.aifitness.groq.GroqClient;
import com.aifitness.groq.GroqPromptBuilder;
import com.aifitness.recommendation.dto.PlanResponse;
import com.aifitness.user.User;
import com.aifitness.user.UserProfile;
import com.aifitness.user.UserProfileRepository;
import com.aifitness.user.UserRepository;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.Data;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RecommendationService {

    private final RecommendationRepository recommendationRepository;
    private final RecommendationExerciseRepository recommendationExerciseRepository;
    private final ExerciseRepository exerciseRepository;
    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final GroqClient groqClient;
    private final GroqPromptBuilder promptBuilder;

    @Transactional(readOnly = true)
    public PlanResponse getCurrentPlan(Long userId) {
        Recommendation rec = recommendationRepository.findTopByUserIdOrderByCreatedAtDesc(userId)
                .orElseThrow(() -> new RuntimeException("No plan found"));

        var exercises = recommendationExerciseRepository.findAllByRecommendationId(rec.getId())
                .stream().map(re -> PlanResponse.PlanExercise.builder()
                        .name(re.getExercise().getName())
                        .dayNumber(re.getDayNumber())
                        .orderIndex(re.getOrderIndex())
                        .sets(re.getSets())
                        .reps(re.getReps())
                        .build())
                .collect(Collectors.toList());

        return PlanResponse.builder()
                .id(rec.getId())
                .status(rec.getStatus())
                .riskLevel(rec.getRiskLevel())
                .planName(rec.getPlanName())
                .weeks(rec.getWeeks())
                .daysPerWeek(rec.getDaysPerWeek())
                .nutritionTarget(rec.getNutritionTarget())
                .exercises(exercises)
                .build();
    }

    @Transactional
    public Recommendation generatePlan(Long userId, String riskLevel, String recommendationStatus) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        UserProfile profile = userProfileRepository.findByUserId(userId).orElse(null);
        String profileContext = "";
        if (profile != null) {
            profileContext = String.format("Gender: %s, Height: %s cm, Weight: %s kg",
                    profile.getGender(), profile.getHeightCm(), profile.getCurrentWeightKg());
        }

        List<Exercise> allExercises = exerciseRepository.findAll();
        String safeExercises = allExercises.stream()
                .filter(Exercise::isActive)
                .map(e -> String.format("ID: %d, Name: %s, Category: %s, Primary Muscle: %s", e.getId(), e.getName(), e.getCategory(), e.getPrimaryMuscle()))
                .collect(Collectors.joining("; "));

        var messages = promptBuilder.buildPlanGenerationPrompt(profileContext, safeExercises);
        String aiResponse = groqClient.getChatCompletion(messages);

        Recommendation plan = new Recommendation();
        plan.setUser(user);
        plan.setStatus(recommendationStatus);
        plan.setRiskLevel(riskLevel);

        List<GeneratedExercise> exercisesToSave = new ArrayList<>();

        try {
            String json = aiResponse.trim();
            if (json.startsWith("```json")) {
                json = json.substring(7);
            }
            if (json.endsWith("```")) {
                json = json.substring(0, json.length() - 3);
            }
            json = json.trim();

            ObjectMapper mapper = new ObjectMapper();
            mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
            GeneratedPlan generated = mapper.readValue(json, GeneratedPlan.class);

            plan.setPlanName(generated.getPlanName() != null ? generated.getPlanName() : "Custom AI Plan");
            plan.setWeeks(generated.getWeeks() != null ? generated.getWeeks() : 12);
            plan.setDaysPerWeek(generated.getDaysPerWeek() != null ? generated.getDaysPerWeek() : 4);
            plan.setMinutesPerSession(generated.getMinutesPerSession() != null ? generated.getMinutesPerSession() : 60);
            plan.setNutritionTarget(generated.getNutritionTarget() != null ? generated.getNutritionTarget() : "Calories: 2000, Protein: 130g, Carbs: 220g, Fat: 70g");

            if (generated.getExercises() != null) {
                exercisesToSave = generated.getExercises();
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Fallback default properties
            plan.setPlanName("Custom AI Plan (Fallback)");
            plan.setWeeks(12);
            plan.setDaysPerWeek(4);
            plan.setMinutesPerSession(60);
            plan.setNutritionTarget("Calories: 2000, Protein: 130g, Carbs: 220g, Fat: 70g");
        }

        final Recommendation savedPlan = recommendationRepository.save(plan);

        if (!exercisesToSave.isEmpty()) {
            for (GeneratedExercise ge : exercisesToSave) {
                Exercise exercise = exerciseRepository.findById(ge.getExerciseId()).orElse(null);
                if (exercise != null) {
                    RecommendationExercise re = new RecommendationExercise();
                    re.setRecommendation(savedPlan);
                    re.setExercise(exercise);
                    re.setDayNumber(ge.getDayNumber() != null ? ge.getDayNumber() : 1);
                    re.setOrderIndex(ge.getOrderIndex() != null ? ge.getOrderIndex() : 1);
                    re.setSets(ge.getSets() != null ? ge.getSets() : 3);
                    re.setReps(ge.getReps() != null ? ge.getReps() : "10");
                    recommendationExerciseRepository.save(re);
                }
            }
        } else {
            // Default exercise fallback if AI didn't provide any valid exercises
            if (!allExercises.isEmpty()) {
                int order = 1;
                for (int i = 0; i < Math.min(4, allExercises.size()); i++) {
                    RecommendationExercise re = new RecommendationExercise();
                    re.setRecommendation(savedPlan);
                    re.setExercise(allExercises.get(i));
                    re.setDayNumber(1);
                    re.setOrderIndex(order++);
                    re.setSets(3);
                    re.setReps("10");
                    recommendationExerciseRepository.save(re);
                }
            }
        }

        return savedPlan;
    }

    @Data
    private static class GeneratedPlan {
        private String planName;
        private Integer weeks;
        private Integer daysPerWeek;
        private Integer minutesPerSession;
        private String nutritionTarget;
        private List<GeneratedExercise> exercises;
    }

    @Data
    private static class GeneratedExercise {
        private Long exerciseId;
        private Integer dayNumber;
        private Integer orderIndex;
        private Integer sets;
        private String reps;
    }
}
