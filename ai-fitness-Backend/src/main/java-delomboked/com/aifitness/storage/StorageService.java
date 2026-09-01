package com.aifitness.storage;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class StorageService {

    // TODO: Configure Supabase URL and Key from application properties
    private String supabaseUrl = "https://your-project.supabase.co";
    private String supabaseKey = "your-anon-key";

    public String uploadFile(MultipartFile file, String bucketName, String path) {
        // Basic stub for MVP.
        // In a real implementation, this would use the Supabase REST API or AWS S3 SDK to upload the file to the specified bucket.
        // E.g., POST https://{supabaseUrl}/storage/v1/object/{bucketName}/{path}

        System.out.println("Uploading file " + file.getOriginalFilename() + " to " + bucketName + "/" + path);

        return supabaseUrl + "/storage/v1/object/public/" + bucketName + "/" + path;
    }
}
