package com.aifitness.health;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    @GetMapping({"/", "/health", "/api/v1/health"})
    public ResponseEntity<Map<String, Object>> getHealth() {
        return ResponseEntity.ok(Map.of(
            "status", "UP",
            "service", "ai-fitness-backend",
            "version", "0.3.0",
            "timestamp", System.currentTimeMillis()
        ));
    }
}

