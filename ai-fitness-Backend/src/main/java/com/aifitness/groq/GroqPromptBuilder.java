package com.aifitness.groq;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Component;

@Component
public class GroqPromptBuilder {

    public List<Map<String, String>> buildPlanGenerationPrompt(String userProfile, String safeExercises) {
        String systemMsg = "You are an AI fitness coach generating personalized workout plans. " +
                "You must ONLY use the exercises provided in the safe pool below. Do NOT invent exercises. " +
                "Respond strictly in JSON format representing the plan. Do not include conversational text. " +
                "The JSON schema must be:\n" +
                "{\n" +
                "  \"planName\": \"string\",\n" +
                "  \"weeks\": 12,\n" +
                "  \"daysPerWeek\": 4,\n" +
                "  \"minutesPerSession\": 60,\n" +
                "  \"nutritionTarget\": \"Calories: X, Protein: Yg, Carbs: Zg, Fat: Wg\",\n" +
                "  \"exercises\": [\n" +
                "    {\n" +
                "      \"exerciseId\": 1,\n" +
                "      \"dayNumber\": 1,\n" +
                "      \"orderIndex\": 1,\n" +
                "      \"sets\": 3,\n" +
                "      \"reps\": \"10-12\"\n" +
                "    }\n" +
                "  ]\n" +
                "}";

        String userMsg = "User Profile: " + userProfile + "\n\n" +
                "Safe Exercise Pool: " + safeExercises + "\n\n" +
                "Generate the workout plan.";

        return List.of(
                Map.of("role", "system", "content", systemMsg),
                Map.of("role", "user", "content", userMsg)
        );
    }

    public List<Map<String, String>> buildCoachPrompt(String context, String userMessage) {
        String systemMsg = "You are an AI fitness coach. You give helpful advice based on the user's current workout and nutrition context.\n\nContext:\n" + context;

        return List.of(
                Map.of("role", "system", "content", systemMsg),
                Map.of("role", "user", "content", userMessage)
        );
    }
}
