package com.aifitness.user;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserFoodRepository extends JpaRepository<UserFood, Long> {
    List<UserFood> findAllByUserId(Long userId);
    void deleteAllByUserId(Long userId);
}
