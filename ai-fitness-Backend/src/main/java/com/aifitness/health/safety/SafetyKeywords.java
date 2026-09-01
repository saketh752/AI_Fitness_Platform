package com.aifitness.health.safety;

import java.util.Arrays;
import java.util.List;

public class SafetyKeywords {

    public static final List<String> HIGH_RISK_KEYWORDS = Arrays.asList(
            "chest pain",
            "heart attack",
            "dizzy",
            "faint",
            "loss of balance",
            "sharp pain",
            "severe pain",
            "torn muscle",
            "fracture",
            "broken bone",
            "surgery",
            "pregnant",
            "stroke"
    );

    public static boolean containsHighRiskKeyword(String input) {
        if (input == null || input.trim().isEmpty()) {
            return false;
        }

        String lowerInput = input.toLowerCase();
        for (String keyword : HIGH_RISK_KEYWORDS) {
            if (lowerInput.contains(keyword)) {
                return true;
            }
        }
        return false;
    }
}
