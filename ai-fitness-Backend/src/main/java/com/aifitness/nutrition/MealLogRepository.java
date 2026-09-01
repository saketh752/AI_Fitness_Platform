package com.aifitness.nutrition;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MealLogRepository extends JpaRepository<MealLog, Long> {
    List<MealLog> findByUserIdAndLogDateOrderByLoggedAtDesc(Long userId, LocalDate logDate);
    List<MealLog> findByUserIdOrderByLoggedAtDesc(Long userId);
    void deleteByIdAndUserId(Long id, Long userId);
}

