package com.aifitness.workout;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import com.aifitness.recommendation.Exercise;

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
@Table(name = "exercise_performances")
@Data
@NoArgsConstructor
public class ExercisePerformance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workout_session_id", nullable = false)
    private WorkoutSession workoutSession;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exercise_id", nullable = false)
    private Exercise exercise;

    @Column(name = "exercise_order", nullable = false)
    private Integer exerciseOrder;

    @Column(name = "planned_sets")
    private Integer plannedSets;

    @Column(name = "completed_sets", nullable = false)
    private Integer completedSets = 0;

    @Column(name = "actual_reps", length = 100)
    private String actualReps;

    @Column(name = "actual_weight_kg", precision = 7, scale = 2)
    private BigDecimal actualWeightKg;

    @Column(name = "perceived_difficulty")
    private Integer perceivedDifficulty;

    @Column(name = "pain_reported", nullable = false)
    private boolean painReported = false;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}

