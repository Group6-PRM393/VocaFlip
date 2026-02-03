package com.vocaflipbackend.service.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.vocaflipbackend.exception.AppException;
import com.vocaflipbackend.exception.ErrorCode;
import com.vocaflipbackend.service.CloudinaryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class CloudinaryServiceImpl implements CloudinaryService {

    private final Cloudinary cloudinary;

    @Override
    public Map<String, Object> uploadFile(MultipartFile file, String folder) {
        try {
            if (file.isEmpty()) {
                throw new AppException(ErrorCode.FILE_EMPTY);
            }

            Map<String, Object> options = ObjectUtils.asMap(
                    "folder", folder,
                    "resource_type", "auto"
            );

            Map<String, Object> result = cloudinary.uploader().upload(file.getBytes(), options);
            log.info("File uploaded successfully: {}", result.get("secure_url"));
            return result;

        } catch (IOException e) {
            log.error("Error uploading file to Cloudinary: {}", e.getMessage());
            throw new AppException(ErrorCode.FILE_UPLOAD_FAILED);
        }
    }


    @Override
    public Map<String, Object> uploadImage(MultipartFile file, String folder, int width, int height) {
        try {
            if (file.isEmpty()) {
                throw new AppException(ErrorCode.FILE_EMPTY);
            }

            // Validate file type is image
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                throw new AppException(ErrorCode.INVALID_FILE_TYPE);
            }

            Map<String, Object> options = ObjectUtils.asMap(
                    "folder", folder,
                    "resource_type", "image",
                    "transformation", new com.cloudinary.Transformation()
                            .width(width)
                            .height(height)
                            .crop("fill")
                            .quality("auto")
            );

            Map<String, Object> result = cloudinary.uploader().upload(file.getBytes(), options);
            log.info("Image uploaded successfully: {}", result.get("secure_url"));
            return result;

        } catch (IOException e) {
            log.error("Error uploading image to Cloudinary: {}", e.getMessage());
            throw new AppException(ErrorCode.FILE_UPLOAD_FAILED);
        }
    }
}
