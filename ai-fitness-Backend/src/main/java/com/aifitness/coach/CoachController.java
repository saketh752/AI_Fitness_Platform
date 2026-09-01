package com.aifitness.coach;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.aifitness.coach.dto.ChatRequest;
import com.aifitness.coach.dto.ChatResponse;
import com.aifitness.coach.dto.CoachMessageDto;
import com.aifitness.common.ApiResponse;
import com.aifitness.user.User;
import com.aifitness.user.UserRepository;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/coach")
@RequiredArgsConstructor
public class CoachController {

    private final CoachService coachService;
    private final UserRepository userRepository;

    @PostMapping("/chat")
    public ResponseEntity<ApiResponse<ChatResponse>> chat(@Valid @RequestBody ChatRequest request) {
        Long userId = getAuthenticatedUserId();
        ChatResponse response = coachService.chat(userId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "AI Coach response ready"));
    }

    @GetMapping("/history")
    public ResponseEntity<ApiResponse<List<CoachMessageDto>>> getHistory() {
        Long userId = getAuthenticatedUserId();
        List<CoachMessageDto> history = coachService.getHistory(userId);
        return ResponseEntity.ok(ApiResponse.success(history, "Coach conversation history"));
    }

    private Long getAuthenticatedUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = ((UserDetails) auth.getPrincipal()).getUsername();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return user.getId();
    }
}
