package com.aifitness.nutrition;

import java.time.LocalDate;

import com.aifitness.user.User;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "nutrition_targets")
@Data
@NoArgsConstructor
public class NutritionTarget {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private LocalDate targetDate;

    private Integer caloriesTarget;
    private Integer proteinGramsTarget;
    private Integer carbsGramsTarget;
    private Integer fatGramsTarget;

    private Integer caloriesConsumed = 0;
}
