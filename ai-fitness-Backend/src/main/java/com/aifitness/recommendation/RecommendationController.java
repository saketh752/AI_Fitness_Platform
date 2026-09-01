package com.aifitness.recommendation;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.aifitness.common.ApiResponse;
import com.aifitness.progress.Progress;
import com.aifitness.progress.ProgressService;
import com.aifitness.recommendation.dto.PlanResponse;
import com.aifitness.recommendation.dto.WorkoutLogRequest;
import com.aifitness.user.User;
import com.aifitness.user.UserRepository;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/recommendations")
@RequiredArgsConstructor
public class RecommendationController {

    private final RecommendationService recommendationService;
    private final ProgressService progressService;
    private final UserRepository userRepository;

    @GetMapping("/current")
    public ResponseEntity<ApiResponse<PlanResponse>> getCurrentPlan() {
        Long userId = getAuthenticatedUserId();
        PlanResponse response = recommendationService.getCurrentPlan(userId);
        return ResponseEntity.ok(ApiResponse.success(response, "Current plan retrieved"));
    }

    @PostMapping("/log-workout")
    public ResponseEntity<ApiResponse<Progress>> logWorkout(@RequestBody WorkoutLogRequest request) {
        Long userId = getAuthenticatedUserId();
        int calories = request.getCaloriesBurned() != null ? request.getCaloriesBurned() : 250;
        int duration = request.getDurationMinutes() != null ? request.getDurationMinutes() : 30;

        Progress progress = progressService.recordProgress(userId, calories, duration);
        return ResponseEntity.ok(ApiResponse.success(progress, "Workout logged successfully"));
    }

    private Long getAuthenticatedUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = ((UserDetails) auth.getPrincipal()).getUsername();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return user.getId();
    }
}
