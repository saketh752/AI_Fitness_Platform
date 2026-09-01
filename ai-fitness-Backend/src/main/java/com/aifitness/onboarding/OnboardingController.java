package com.aifitness.onboarding;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.aifitness.common.ApiResponse;
import com.aifitness.onboarding.dto.OnboardingRequest;
import com.aifitness.onboarding.dto.OnboardingResponse;
import com.aifitness.user.User;
import com.aifitness.user.UserRepository;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/onboarding")
@RequiredArgsConstructor
public class OnboardingController {

    private final OnboardingService onboardingService;
    private final UserRepository userRepository;

    @PostMapping("/complete")
    public ResponseEntity<ApiResponse<OnboardingResponse>> completeOnboarding(@RequestBody OnboardingRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = ((UserDetails) auth.getPrincipal()).getUsername();

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        OnboardingResponse response = onboardingService.completeOnboarding(user.getId(), request);
        return ResponseEntity.ok(ApiResponse.success(response, "Onboarding complete"));
    }
}
