package com.aifitness.progress;

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

import com.aifitness.progress.dto.ProgressSummary;
import com.aifitness.progress.dto.WeightLogDto;
import com.aifitness.user.User;
import com.aifitness.user.UserProfileRepository;
import com.aifitness.user.UserRepository;

@ExtendWith(MockitoExtension.class)
class ProgressServiceTest {

    @Mock
    private ProgressRepository progressRepository;

    @Mock
    private WeightLogRepository weightLogRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private UserProfileRepository userProfileRepository;

    @InjectMocks
    private ProgressService progressService;

    private User testUser;
    private Progress testProgress;
    private WeightLog testWeight;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);

        testProgress = new Progress();
        testProgress.setUser(testUser);
        testProgress.setDate(LocalDate.now());
        testProgress.setWorkoutsCompleted(4);
        testProgress.setCaloriesBurned(1200);
        testProgress.setActiveMinutes(180);
        testProgress.setStreakDays(5);

        testWeight = WeightLog.builder()
                .id(1L)
                .user(testUser)
                .weightKg(new BigDecimal("75.50"))
                .logDate(LocalDate.now())
                .notes("Morning weigh-in")
                .build();
    }

    @Test
    void getSummary_CalculatesTotalsAndStreak() {
        when(progressRepository.findAllByUserIdOrderByDateDesc(1L)).thenReturn(List.of(testProgress));
        when(weightLogRepository.findByUserIdOrderByLogDateAsc(1L)).thenReturn(List.of(testWeight));

        ProgressSummary summary = progressService.getSummary(1L);

        assertNotNull(summary);
        assertEquals(4, summary.getTotalWorkoutsCompleted());
        assertEquals(1200, summary.getTotalCaloriesBurned());
        assertEquals(180, summary.getTotalActiveMinutes());
        assertEquals(5, summary.getCurrentStreak());
    }

    @Test
    void logWeight_SavesWeightAndUpdatesProfile() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(weightLogRepository.findByUserIdAndLogDate(1L, LocalDate.now())).thenReturn(Optional.empty());
        when(weightLogRepository.save(any(WeightLog.class))).thenReturn(testWeight);
        when(userProfileRepository.findByUserId(1L)).thenReturn(Optional.empty());

        WeightLogDto request = WeightLogDto.builder()
                .weightKg(new BigDecimal("75.50"))
                .notes("Morning weigh-in")
                .build();

        WeightLogDto result = progressService.logWeight(1L, request);

        assertNotNull(result);
        assertEquals(new BigDecimal("75.50"), result.getWeightKg());
        verify(weightLogRepository).save(any(WeightLog.class));
    }

    @Test
    void recordProgress_UpdatesCaloriesAndWorkouts() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(progressRepository.findByUserIdAndDate(1L, LocalDate.now())).thenReturn(Optional.of(testProgress));
        when(progressRepository.findAllByUserIdOrderByDateDesc(1L)).thenReturn(List.of(testProgress));
        when(progressRepository.save(any(Progress.class))).thenReturn(testProgress);

        Progress result = progressService.recordProgress(1L, 300, 45);

        assertNotNull(result);
        verify(progressRepository).save(any(Progress.class));
    }
}

