package com.aifitness.user;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.aifitness.common.ApiResponse;
import com.aifitness.user.dto.UserProfileDto;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/profile")
@RequiredArgsConstructor
public class UserProfileController {

    private final UserProfileService userProfileService;
    private final UserRepository userRepository;

    @GetMapping
    public ResponseEntity<ApiResponse<UserProfileDto>> getProfile() {
        Long userId = getAuthenticatedUserId();
        UserProfileDto profile = userProfileService.getProfile(userId);
        return ResponseEntity.ok(ApiResponse.success(profile, "Profile retrieved"));
    }

    @PutMapping
    public ResponseEntity<ApiResponse<UserProfileDto>> updateProfile(@RequestBody UserProfileDto request) {
        Long userId = getAuthenticatedUserId();
        UserProfileDto updated = userProfileService.updateProfile(userId, request);
        return ResponseEntity.ok(ApiResponse.success(updated, "Profile updated successfully"));
    }

    private Long getAuthenticatedUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = ((UserDetails) auth.getPrincipal()).getUsername();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return user.getId();
    }
}

