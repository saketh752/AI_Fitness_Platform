package com.aifitness.nutrition;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.aifitness.user.User;

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
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "meal_logs")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "meal_type", nullable = false, length = 50)
    private String mealType;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private Integer calories;

    @Column(name = "protein_grams")
    private Integer proteinGrams;

    @Column(name = "carbs_grams")
    private Integer carbsGrams;

    @Column(name = "fat_grams")
    private Integer fatGrams;

    @Column(name = "log_date", nullable = false)
    private LocalDate logDate;

    @Column(name = "logged_at", nullable = false)
    private LocalDateTime loggedAt;

    @PrePersist
    protected void onCreate() {
        if (logDate == null) {
            logDate = LocalDate.now();
        }
        if (loggedAt == null) {
            loggedAt = LocalDateTime.now();
        }
    }
}

