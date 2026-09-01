package com.aifitness.form_analysis.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FormAnalysisResponse {
    private String status;
    private String message;
    private String exerciseCode;
    private int score;
    private String feedback;
    private String videoUrl;
}
