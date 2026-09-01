package com.aifitness.coach.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CoachMessageDto {
    private Long id;
    private String message;
    private String response;
    private String status;
    private LocalDateTime createdAt;
}

