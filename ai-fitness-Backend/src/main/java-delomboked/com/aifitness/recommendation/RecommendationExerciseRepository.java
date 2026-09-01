package com.aifitness.recommendation;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RecommendationExerciseRepository extends JpaRepository<RecommendationExercise, Long> {
    List<RecommendationExercise> findAllByRecommendationId(Long recommendationId);
}
