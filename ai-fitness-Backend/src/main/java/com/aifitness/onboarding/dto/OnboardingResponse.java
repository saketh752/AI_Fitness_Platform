package com.aifitness.onboarding.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class OnboardingResponse {
    private String status;       // SAFE | MODIFIED | MEDICAL_REVIEW
    private String riskLevel;    // LOW | MODERATE | HIGH
    private Long recommendationId;
    private String message;
}
