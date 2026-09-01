package com.aifitness.coach;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CoachConversationRepository extends JpaRepository<CoachConversation, Long> {
    List<CoachConversation> findAllByUserIdOrderByCreatedAtDesc(Long userId);
}
