package com.aifitness.health.assessment;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserConditionRepository extends JpaRepository<UserCondition, Long> {
    List<UserCondition> findAllByUserId(Long userId);
    void deleteAllByUserId(Long userId);
}
