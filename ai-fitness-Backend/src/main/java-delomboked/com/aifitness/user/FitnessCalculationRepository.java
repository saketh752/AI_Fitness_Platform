package com.aifitness.user;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FitnessCalculationRepository extends JpaRepository<FitnessCalculation, Long> {
    List<FitnessCalculation> findByUserId(Long userId);
    List<FitnessCalculation> findByUserIdOrderByCalculatedAtDesc(Long userId);
}

