package com.aifitness.form_analysis;


import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestTemplate;

import com.aifitness.form_analysis.dto.FormAnalysisResponse;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Component
@RequiredArgsConstructor
@Slf4j
public class PythonCvClient {

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${cv.base-url:http://localhost:5000}")
    private String baseUrl;

    public FormAnalysisResponse callCvService(String videoUrl, String exerciseCode) {
        String url = baseUrl + "/api/analyze";
        log.info("Sending request to Python CV service at {} with videoUrl: {}, exerciseCode: {}", url, videoUrl, exerciseCode);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, String> requestBody = Map.of(
                "video_url", videoUrl,
                "exercise_code", exerciseCode
        );

        HttpEntity<Map<String, String>> entity = new HttpEntity<>(requestBody, headers);

        try {
            FormAnalysisResponse response = restTemplate.postForObject(url, entity, FormAnalysisResponse.class);
            if (response == null) {
                throw new RuntimeException("Received empty response from CV service");
            }
            return response;
        } catch (ResourceAccessException e) {
            log.error("Python CV service is unavailable at {}", url, e);
            throw new RuntimeException("Python CV service is currently unavailable. Please try again later.");
        } catch (HttpClientErrorException | HttpServerErrorException e) {
            log.error("Error response from Python CV service: {} - {}", e.getStatusCode(), e.getResponseBodyAsString(), e);
            throw new IllegalArgumentException("Exercise analysis failed: " + e.getResponseBodyAsString());
        } catch (Exception e) {
            log.error("Unexpected error during Python CV call", e);
            throw new RuntimeException("An unexpected error occurred during form analysis.");
        }
    }
}

