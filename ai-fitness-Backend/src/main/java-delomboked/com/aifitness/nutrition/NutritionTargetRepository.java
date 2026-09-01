package com.aifitness.nutrition;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface NutritionTargetRepository extends JpaRepository<NutritionTarget, Long> {
    Optional<NutritionTarget> findByUserIdAndTargetDate(Long userId, LocalDate targetDate);
    List<NutritionTarget> findByUserIdOrderByTargetDateDesc(Long userId);
}

