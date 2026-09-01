package com.aifitness.user;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserConstraintRepository extends JpaRepository<UserConstraint, Long> {
    List<UserConstraint> findByUserId(Long userId);
    List<UserConstraint> findByUserIdAndIsActive(Long userId, boolean isActive);
}

