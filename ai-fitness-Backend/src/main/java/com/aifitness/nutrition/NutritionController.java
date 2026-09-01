package com.aifitness.nutrition;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.aifitness.common.ApiResponse;
import com.aifitness.nutrition.dto.MealDto;
import com.aifitness.nutrition.dto.NutritionSummaryDto;
import com.aifitness.user.User;
import com.aifitness.user.UserRepository;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/nutrition")
@RequiredArgsConstructor
public class NutritionController {

    private final NutritionService nutritionService;
    private final UserRepository userRepository;

    @GetMapping("/today")
    public ResponseEntity<ApiResponse<NutritionSummaryDto>> getTodaySummary() {
        Long userId = getAuthenticatedUserId();
        NutritionSummaryDto summary = nutritionService.getTodaySummary(userId);
        return ResponseEntity.ok(ApiResponse.success(summary, "Today's nutrition summary"));
    }

    @PostMapping("/log-meal")
    public ResponseEntity<ApiResponse<MealDto>> logMeal(@RequestBody MealDto request) {
        Long userId = getAuthenticatedUserId();
        MealDto logged = nutritionService.logMeal(userId, request);
        return ResponseEntity.ok(ApiResponse.success(logged, "Meal logged successfully"));
    }

    @DeleteMapping("/meals/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteMeal(@PathVariable Long id) {
        Long userId = getAuthenticatedUserId();
        nutritionService.deleteMeal(userId, id);
        return ResponseEntity.ok(ApiResponse.success(null, "Meal deleted successfully"));
    }

    @GetMapping("/meals")
    public ResponseEntity<ApiResponse<List<MealDto>>> getTodayMeals() {
        Long userId = getAuthenticatedUserId();
        List<MealDto> meals = nutritionService.getTodayMeals(userId);
        return ResponseEntity.ok(ApiResponse.success(meals, "Today's meals"));
    }

    private Long getAuthenticatedUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = ((UserDetails) auth.getPrincipal()).getUsername();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return user.getId();
    }
}
