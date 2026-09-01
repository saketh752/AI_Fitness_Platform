package com.aifitness.coach.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ChatResponse {
    private String status;    // SAFE | MEDICAL_REVIEW
    private String response;
    private Long conversationId;
}
