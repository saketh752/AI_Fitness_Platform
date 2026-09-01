package com.aifitness.user;

import java.time.LocalDate;
import java.time.Period;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.aifitness.user.dto.UserProfileDto;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserProfileService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final UserGoalRepository userGoalRepository;

    @Transactional(readOnly = true)
    public UserProfileDto getProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        UserProfile profile = userProfileRepository.findByUserId(userId).orElse(null);
        UserGoal goal = userGoalRepository.findByUserIdAndStatus(userId, "ACTIVE")
                .stream().findFirst().orElse(null);

        Integer age = null;
        if (profile != null && profile.getDateOfBirth() != null) {
            age = Period.between(profile.getDateOfBirth(), LocalDate.now()).getYears();
        }

        return UserProfileDto.builder()
                .userId(user.getId())
                .email(user.getEmail())
                .fullName(profile != null ? profile.getFullName() : "")
                .age(age)
                .gender(profile != null ? profile.getGender() : "")
                .heightCm(profile != null ? profile.getHeightCm() : null)
                .currentWeightKg(profile != null ? profile.getCurrentWeightKg() : null)
                .fitnessGoal(goal != null ? goal.getGoalType() : "")
                .activityLevel(profile != null ? profile.getActivityLevel() : "")
                .fitnessExperience(profile != null ? profile.getFitnessExperience() : "")
                .build();
    }

    @Transactional
    public UserProfileDto updateProfile(Long userId, UserProfileDto request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        UserProfile profile = userProfileRepository.findByUserId(userId).orElseGet(() -> {
            UserProfile p = new UserProfile();
            p.setUser(user);
            return p;
        });

        if (request.getFullName() != null) {
            profile.setFullName(request.getFullName().trim());
        }
        if (request.getGender() != null) {
            profile.setGender(request.getGender().trim());
        }
        if (request.getHeightCm() != null) {
            profile.setHeightCm(request.getHeightCm());
        }
        if (request.getCurrentWeightKg() != null) {
            profile.setCurrentWeightKg(request.getCurrentWeightKg());
        }
        if (request.getActivityLevel() != null) {
            profile.setActivityLevel(request.getActivityLevel().trim());
        }
        if (request.getFitnessExperience() != null) {
            profile.setFitnessExperience(request.getFitnessExperience().trim());
        }
        if (request.getAge() != null && request.getAge() > 0) {
            profile.setDateOfBirth(LocalDate.now().minusYears(request.getAge()));
        }

        userProfileRepository.save(profile);

        if (request.getFitnessGoal() != null && !request.getFitnessGoal().isBlank()) {
            UserGoal goal = userGoalRepository.findByUserIdAndStatus(userId, "ACTIVE")
                    .stream().findFirst().orElseGet(() -> {
                        UserGoal g = new UserGoal();
                        g.setUser(user);
                        g.setStatus("ACTIVE");
                        return g;
                    });
            goal.setGoalType(request.getFitnessGoal().trim());
            userGoalRepository.save(goal);
        }

        return getProfile(userId);
    }
}

