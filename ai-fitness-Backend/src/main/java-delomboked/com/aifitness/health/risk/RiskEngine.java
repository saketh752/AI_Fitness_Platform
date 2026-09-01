package com.aifitness.health.risk;

import java.util.List;

import org.springframework.stereotype.Service;

import com.aifitness.health.assessment.UserCondition;

@Service
public class RiskEngine {

    public RiskAssessment assessRisk(List<UserCondition> conditions) {
        if (conditions == null || conditions.isEmpty()) {
            return new RiskAssessment(RiskLevel.LOW, RecommendationStatus.SAFE);
        }

        boolean hasHighRisk = false;
        boolean hasModerateRisk = false;

        for (UserCondition uc : conditions) {
            String defaultRiskStr = uc.getCondition().getDefaultRiskLevel();
            RiskLevel defaultRisk = RiskLevel.valueOf(defaultRiskStr);

            RiskLevel calculatedRisk = defaultRisk;

            // Adjust based on severity (if present)
            if ("SEVERE".equalsIgnoreCase(uc.getSeverity())) {
                if (defaultRisk == RiskLevel.MODERATE) {
                    calculatedRisk = RiskLevel.HIGH;
                }
            } else if ("MILD".equalsIgnoreCase(uc.getSeverity())) {
                if (defaultRisk == RiskLevel.HIGH) {
                    calculatedRisk = RiskLevel.MODERATE;
                }
            }

            // Adjust based on recency
            if (uc.isRecent() && calculatedRisk != RiskLevel.HIGH) {
                // If it's a recent injury, bump up the risk
                if (calculatedRisk == RiskLevel.LOW) {
                    calculatedRisk = RiskLevel.MODERATE;
                } else if (calculatedRisk == RiskLevel.MODERATE) {
                    calculatedRisk = RiskLevel.HIGH;
                }
            }

            if (calculatedRisk == RiskLevel.HIGH) {
                hasHighRisk = true;
                break; // Stop evaluating, we're already at max risk
            } else if (calculatedRisk == RiskLevel.MODERATE) {
                hasModerateRisk = true;
            }
        }

        if (hasHighRisk) {
            return new RiskAssessment(RiskLevel.HIGH, RecommendationStatus.MEDICAL_REVIEW);
        } else if (hasModerateRisk) {
            return new RiskAssessment(RiskLevel.MODERATE, RecommendationStatus.MODIFIED);
        } else {
            return new RiskAssessment(RiskLevel.LOW, RecommendationStatus.SAFE);
        }
    }

    public record RiskAssessment(RiskLevel riskLevel, RecommendationStatus status) {}
}
