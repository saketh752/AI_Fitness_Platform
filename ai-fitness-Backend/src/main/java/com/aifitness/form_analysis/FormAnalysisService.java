package com.aifitness.form_analysis;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.aifitness.form_analysis.dto.FormAnalysisResponse;
import com.aifitness.storage.StorageService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class FormAnalysisService {

    private final StorageService storageService;
    private final PythonCvClient pythonCvClient;

    public FormAnalysisResponse analyzeForm(Long userId, String exerciseCode, MultipartFile videoFile) {
        // 1. Upload video to Storage
        String path = "users/" + userId + "/form-analysis/" + System.currentTimeMillis() + "_" + videoFile.getOriginalFilename();
        String videoUrl = storageService.uploadFile(videoFile, "videos", path);

        // 2. Call Python CV service with the video URL
        return pythonCvClient.callCvService(videoUrl, exerciseCode);
    }
}
