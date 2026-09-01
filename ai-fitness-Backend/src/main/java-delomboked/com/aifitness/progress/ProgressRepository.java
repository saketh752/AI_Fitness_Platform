package com.aifitness.progress;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProgressRepository extends JpaRepository<Progress, Long> {
    Optional<Progress> findByUserIdAndDate(Long userId, LocalDate date);
    List<Progress> findAllByUserIdOrderByDateDesc(Long userId);
}
