package com.aifitness.groq;

import org.springframework.boot.context.properties.ConfigurationProperties;

import lombok.Data;

@ConfigurationProperties(prefix = "groq")
@Data
public class GroqConfig {
    private String apiKey;
    private String model;
    private String baseUrl;
}
