package com.aifitness.user;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "fitness_calculations")
@Data
@NoArgsConstructor
public class FitnessCalculation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(precision = 6, scale = 2)
    private BigDecimal bmi;

    @Column(precision = 10, scale = 2)
    private BigDecimal bmr;

    @Column(precision = 10, scale = 2)
    private BigDecimal tdee;

    @Column(name = "calorie_target", precision = 10, scale = 2)
    private BigDecimal calorieTarget;

    @Column(name = "protein_target_g", precision = 10, scale = 2)
    private BigDecimal proteinTargetG;

    @Column(name = "carbs_target_g", precision = 10, scale = 2)
    private BigDecimal carbsTargetG;

    @Column(name = "fat_target_g", precision = 10, scale = 2)
    private BigDecimal fatTargetG;

    @Column(name = "calculation_version", nullable = false, length = 30)
    private String calculationVersion = "V1";

    @Column(name = "calculated_at", nullable = false)
    private LocalDateTime calculatedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        if (calculatedAt == null) {
            calculatedAt = now;
        }
        createdAt = now;
    }
}

