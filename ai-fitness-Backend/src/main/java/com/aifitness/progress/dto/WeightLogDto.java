package com.aifitness.progress.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeightLogDto {
    private Long id;
    private BigDecimal weightKg;
    private LocalDate logDate;
    private String notes;
}

