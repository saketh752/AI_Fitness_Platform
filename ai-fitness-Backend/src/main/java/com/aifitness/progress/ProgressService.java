package com.aifitness.progress;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.aifitness.progress.dto.ProgressSummary;
import com.aifitness.progress.dto.WeightLogDto;
import com.aifitness.user.User;
import com.aifitness.user.UserProfile;
import com.aifitness.user.UserProfileRepository;
import com.aifitness.user.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ProgressService {

    private final ProgressRepository progressRepository;
    private final WeightLogRepository weightLogRepository;
    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;

    @Transactional(readOnly = true)
    public ProgressSummary getSummary(Long userId) {
        List<Progress> history = progressRepository.findAllByUserIdOrderByDateDesc(userId);

        int totalWorkouts = history.stream().mapToInt(Progress::getWorkoutsCompleted).sum();
        int totalCalories = history.stream().mapToInt(Progress::getCaloriesBurned).sum();
        int totalMinutes = history.stream().mapToInt(Progress::getActiveMinutes).sum();
        int streak = history.isEmpty() ? 0 : history.get(0).getStreakDays();

        // Also get starting and current weight
        List<WeightLog> weights = weightLogRepository.findByUserIdOrderByLogDateAsc(userId);
        BigDecimal currentWeight = null;
        BigDecimal startWeight = null;

        if (!weights.isEmpty()) {
            startWeight = weights.get(0).getWeightKg();
            currentWeight = weights.get(weights.size() - 1).getWeightKg();
        } else {
            UserProfile profile = userProfileRepository.findByUserId(userId).orElse(null);
            if (profile != null) {
                currentWeight = profile.getCurrentWeightKg();
                startWeight = profile.getCurrentWeightKg();
            }
        }

        return ProgressSummary.builder()
                .totalWorkoutsCompleted(totalWorkouts)
                .totalCaloriesBurned(totalCalories)
                .totalActiveMinutes(totalMinutes)
                .currentStreak(streak)
                .caloriesBurnedDisplay(totalCalories + " kcal")
                .activeMinutesDisplay(totalMinutes + " min")
                .streakDisplay(streak + " Days")
                .build();
    }

    @Transactional(readOnly = true)
    public List<Progress> getHistory(Long userId) {
        return progressRepository.findAllByUserIdOrderByDateDesc(userId);
    }

    @Transactional
    public WeightLogDto logWeight(Long userId, WeightLogDto dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        LocalDate date = dto.getLogDate() != null ? dto.getLogDate() : LocalDate.now();

        WeightLog log = weightLogRepository.findByUserIdAndLogDate(userId, date)
                .orElseGet(() -> WeightLog.builder()
                        .user(user)
                        .logDate(date)
                        .build());

        log.setWeightKg(dto.getWeightKg());
        log.setNotes(dto.getNotes());
        WeightLog saved = weightLogRepository.save(log);

        // Update profile current weight
        UserProfile profile = userProfileRepository.findByUserId(userId).orElse(null);
        if (profile != null) {
            profile.setCurrentWeightKg(dto.getWeightKg());
            userProfileRepository.save(profile);
        }

        return WeightLogDto.builder()
                .id(saved.getId())
                .weightKg(saved.getWeightKg())
                .logDate(saved.getLogDate())
                .notes(saved.getNotes())
                .build();
    }

    @Transactional(readOnly = true)
    public List<WeightLogDto> getWeightHistory(Long userId) {
        return weightLogRepository.findByUserIdOrderByLogDateAsc(userId).stream()
                .map(w -> WeightLogDto.builder()
                        .id(w.getId())
                        .weightKg(w.getWeightKg())
                        .logDate(w.getLogDate())
                        .notes(w.getNotes())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public Progress recordProgress(Long userId, int caloriesBurned, int activeMinutes) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        LocalDate today = LocalDate.now();
        Progress progress = progressRepository.findByUserIdAndDate(userId, today)
                .orElseGet(() -> {
                    Progress p = new Progress();
                    p.setUser(user);
                    p.setDate(today);
                    return p;
                });

        progress.setCaloriesBurned(progress.getCaloriesBurned() + caloriesBurned);
        progress.setActiveMinutes(progress.getActiveMinutes() + activeMinutes);
        progress.setWorkoutsCompleted(progress.getWorkoutsCompleted() + 1);

        // Calculate streak
        List<Progress> history = progressRepository.findAllByUserIdOrderByDateDesc(userId);
        int streak = calculateStreak(history, today);
        progress.setStreakDays(streak);

        return progressRepository.save(progress);
    }

    private int calculateStreak(List<Progress> history, LocalDate today) {
        int streak = 1;
        for (int i = 0; i < history.size() - 1; i++) {
            LocalDate current = history.get(i).getDate();
            LocalDate prev = history.get(i + 1).getDate();
            if (current != null && prev != null && current.minusDays(1).equals(prev)) {
                streak++;
            } else {
                break;
            }
        }
        return streak;
    }
}
