package com.aifitness.user;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.aifitness.user.dto.UserProfileDto;

@ExtendWith(MockitoExtension.class)
class UserProfileServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private UserProfileRepository userProfileRepository;

    @Mock
    private UserGoalRepository userGoalRepository;

    @InjectMocks
    private UserProfileService userProfileService;

    private User testUser;
    private UserProfile testProfile;
    private UserGoal testGoal;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("sarah@example.com");

        testProfile = new UserProfile();
        testProfile.setId(1L);
        testProfile.setUser(testUser);
        testProfile.setFullName("Sarah Connor");
        testProfile.setGender("Female");
        testProfile.setHeightCm(new BigDecimal("168.00"));
        testProfile.setCurrentWeightKg(new BigDecimal("62.50"));
        testProfile.setDateOfBirth(LocalDate.now().minusYears(28));
        testProfile.setActivityLevel("Moderate");

        testGoal = new UserGoal();
        testGoal.setId(1L);
        testGoal.setUser(testUser);
        testGoal.setGoalType("Build Muscle");
        testGoal.setStatus("ACTIVE");
    }

    @Test
    void getProfile_ReturnsMappedProfileDto() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(userProfileRepository.findByUserId(1L)).thenReturn(Optional.of(testProfile));
        when(userGoalRepository.findByUserIdAndStatus(1L, "ACTIVE")).thenReturn(List.of(testGoal));

        UserProfileDto dto = userProfileService.getProfile(1L);

        assertNotNull(dto);
        assertEquals("Sarah Connor", dto.getFullName());
        assertEquals("sarah@example.com", dto.getEmail());
        assertEquals(28, dto.getAge());
        assertEquals(new BigDecimal("168.00"), dto.getHeightCm());
        assertEquals(new BigDecimal("62.50"), dto.getCurrentWeightKg());
        assertEquals("Build Muscle", dto.getFitnessGoal());
    }

    @Test
    void updateProfile_ModifiesAndSavesProfile() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(userProfileRepository.findByUserId(1L)).thenReturn(Optional.of(testProfile));
        when(userGoalRepository.findByUserIdAndStatus(1L, "ACTIVE")).thenReturn(List.of(testGoal));

        UserProfileDto request = UserProfileDto.builder()
                .fullName("Sarah C. Reese")
                .age(29)
                .gender("Female")
                .heightCm(new BigDecimal("170.00"))
                .currentWeightKg(new BigDecimal("61.00"))
                .fitnessGoal("Endurance")
                .activityLevel("Very Active")
                .build();

        UserProfileDto result = userProfileService.updateProfile(1L, request);

        verify(userProfileRepository).save(any(UserProfile.class));
        verify(userGoalRepository).save(any(UserGoal.class));
        assertNotNull(result);
    }
}

