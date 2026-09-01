package com.aifitness.coach;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.aifitness.coach.dto.ChatRequest;
import com.aifitness.coach.dto.ChatResponse;
import com.aifitness.coach.dto.CoachMessageDto;
import com.aifitness.groq.GroqClient;
import com.aifitness.groq.GroqPromptBuilder;
import com.aifitness.health.assessment.UserCondition;
import com.aifitness.health.assessment.UserConditionRepository;
import com.aifitness.health.safety.SafetyKeywords;
import com.aifitness.nutrition.NutritionService;
import com.aifitness.nutrition.dto.NutritionSummaryDto;
import com.aifitness.recommendation.Recommendation;
import com.aifitness.recommendation.RecommendationRepository;
import com.aifitness.user.User;
import com.aifitness.user.UserGoal;
import com.aifitness.user.UserGoalRepository;
import com.aifitness.user.UserProfile;
import com.aifitness.user.UserProfileRepository;
import com.aifitness.user.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class CoachService {

    private final CoachConversationRepository conversationRepository;
    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final UserGoalRepository userGoalRepository;
    private final UserConditionRepository userConditionRepository;
    private final RecommendationRepository recommendationRepository;
    private final NutritionService nutritionService;
    private final GroqClient groqClient;
    private final GroqPromptBuilder promptBuilder;

    @Transactional
    public ChatResponse chat(Long userId, ChatRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String userMessage = request.getMessage().trim();

        // PRE-FILTER: Check for high-risk keywords before calling Groq
        if (SafetyKeywords.containsHighRiskKeyword(userMessage)) {
            CoachConversation conversation = new CoachConversation();
            conversation.setUser(user);
            conversation.setMessage(userMessage);
            conversation.setStatus("MEDICAL_REVIEW");
            conversation.setResponse(
                "I'm concerned about the pain or symptoms you described. Please stop this exercise immediately and consult a healthcare or physical therapy professional. Your safety comes first."
            );
            conversationRepository.save(conversation);

            return ChatResponse.builder()
                    .status("MEDICAL_REVIEW")
                    .response(conversation.getResponse())
                    .conversationId(conversation.getId())
                    .build();
        }

        // Build rich context from user profile, goals, active workout, and nutrition
        String context = buildUserContext(userId);

        // Call Groq AI
        String aiResponse;
        try {
            var messages = promptBuilder.buildCoachPrompt(context, userMessage);
            aiResponse = groqClient.getChatCompletion(messages);
        } catch (Exception e) {
            log.error("Groq AI completion error: {}", e.getMessage(), e);
            aiResponse = "I am here to guide your workouts, form, and nutrition. Based on your current plan, stay consistent with your routine and ensure you hit your daily protein and recovery targets!";
        }

        // Save conversation to database
        CoachConversation conversation = new CoachConversation();
        conversation.setUser(user);
        conversation.setMessage(userMessage);
        conversation.setResponse(aiResponse);
        conversation.setStatus("SAFE");
        conversationRepository.save(conversation);

        return ChatResponse.builder()
                .status("SAFE")
                .response(aiResponse)
                .conversationId(conversation.getId())
                .build();
    }

    @Transactional(readOnly = true)
    public List<CoachMessageDto> getHistory(Long userId) {
        return conversationRepository.findAllByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(c -> CoachMessageDto.builder()
                        .id(c.getId())
                        .message(c.getMessage())
                        .response(c.getResponse())
                        .status(c.getStatus())
                        .createdAt(c.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }

    private String buildUserContext(Long userId) {
        UserProfile profile = userProfileRepository.findByUserId(userId).orElse(null);
        String name = profile != null ? profile.getFullName() : "Athlete";
        String gender = profile != null ? profile.getGender() : "N/A";
        String height = profile != null && profile.getHeightCm() != null ? profile.getHeightCm() + "cm" : "N/A";
        String weight = profile != null && profile.getCurrentWeightKg() != null ? profile.getCurrentWeightKg() + "kg" : "N/A";
        String activity = profile != null ? profile.getActivityLevel() : "Moderate";

        String goal = userGoalRepository.findByUserIdAndStatus(userId, "ACTIVE")
                .stream().findFirst().map(UserGoal::getGoalType).orElse("Build Muscle & Improve Fitness");

        List<String> conditions = userConditionRepository.findAllByUserId(userId)
                .stream()
                .filter(uc -> uc.getCondition() != null && uc.getCondition().getName() != null)
                .map(uc -> uc.getCondition().getName())
                .collect(Collectors.toList());
        String conditionStr = conditions.isEmpty() ? "None reported" : String.join(", ", conditions);

        Recommendation plan = recommendationRepository.findTopByUserIdOrderByCreatedAtDesc(userId).orElse(null);
        String planName = plan != null && plan.getPlanName() != null ? plan.getPlanName() : "Custom Workout Plan";

        NutritionSummaryDto nutrition = nutritionService.getTodaySummary(userId);
        String nutritionStr = String.format("Target: %d kcal (Consumed: %d kcal, Remaining: %d kcal, Protein: %d/%dg)",
                nutrition.getTargetCalories(),
                nutrition.getConsumedCalories(),
                nutrition.getRemainingCalories(),
                nutrition.getConsumedProteinGrams(),
                nutrition.getTargetProteinGrams());

        return String.format(
            "User: %s (Gender: %s, Height: %s, Weight: %s, Activity: %s). Goal: %s. Health Restrictions: %s. Active Workout: %s. Today's Nutrition: %s.",
            name, gender, height, weight, activity, goal, conditionStr, planName, nutritionStr
        );
    }
}
