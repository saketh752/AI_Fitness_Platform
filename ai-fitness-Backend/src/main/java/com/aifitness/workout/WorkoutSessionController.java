package com.aifitness.workout;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.aifitness.common.ApiResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/workout-sessions")
@RequiredArgsConstructor
public class WorkoutSessionController {

    @PostMapping
    public ResponseEntity<ApiResponse<Object>> startSession(@RequestBody Object request) {
        // Stub for starting a session
        return ResponseEntity.ok(ApiResponse.success(null, "Session started"));
    }

    @PostMapping("/{id}/exercise")
    public ResponseEntity<ApiResponse<Object>> logSet(@PathVariable Long id, @RequestBody Object request) {
        // Stub for logging a set
        return ResponseEntity.ok(ApiResponse.success(null, "Set logged"));
    }

    @PostMapping("/{id}/complete")
    public ResponseEntity<ApiResponse<Object>> completeSession(@PathVariable Long id) {
        // Stub for marking session done
        return ResponseEntity.ok(ApiResponse.success(null, "Session completed"));
    }
}
