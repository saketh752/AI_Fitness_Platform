package com.aifitness.progress;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WeightLogRepository extends JpaRepository<WeightLog, Long> {
    List<WeightLog> findByUserIdOrderByLogDateAsc(Long userId);
    List<WeightLog> findByUserIdOrderByLogDateDesc(Long userId);
    Optional<WeightLog> findByUserIdAndLogDate(Long userId, LocalDate logDate);
}

