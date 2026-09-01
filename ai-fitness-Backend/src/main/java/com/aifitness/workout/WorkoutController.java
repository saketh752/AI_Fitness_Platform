package com.aifitness.workout;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.aifitness.common.ApiResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/workouts")
@RequiredArgsConstructor
public class WorkoutController {

    @GetMapping
    public ResponseEntity<ApiResponse<List<Object>>> getWorkouts() {
        // Stub for getting all workouts for the week
        return ResponseEntity.ok(ApiResponse.success(List.of(), "Workouts retrieved"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Object>> getWorkoutDetails(@PathVariable Long id) {
        // Stub for getting workout details
        return ResponseEntity.ok(ApiResponse.success(null, "Workout details retrieved"));
    }
}
