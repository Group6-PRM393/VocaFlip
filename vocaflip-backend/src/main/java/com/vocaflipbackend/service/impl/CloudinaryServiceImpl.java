package com.vocaflipbackend.service.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.Transformation;
import com.cloudinary.utils.ObjectUtils;
import com.vocaflipbackend.constants.CloudinaryConstants;
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

            // Kiểm tra kích thước file
            if (file.getSize() > CloudinaryConstants.MAX_FILE_SIZE) {
                throw new AppException(ErrorCode.FILE_SIZE_EXCEEDED);
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

            // Kiểm tra kích thước file
            if (file.getSize() > CloudinaryConstants.MAX_FILE_SIZE) {
                throw new AppException(ErrorCode.FILE_SIZE_EXCEEDED);
            }

            // Validate file type is image
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                throw new AppException(ErrorCode.INVALID_FILE_TYPE);
            }

            Map<String, Object> options = ObjectUtils.asMap(
                    "folder", folder,
                    "resource_type", "image",
                    "transformation", new Transformation()
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

    @Override
    public String uploadAvatar(MultipartFile file, String userId) {
        try {
            if (file.isEmpty()) {
                throw new AppException(ErrorCode.FILE_EMPTY);
            }

            if (file.getSize() > CloudinaryConstants.MAX_FILE_SIZE) {
                throw new AppException(ErrorCode.FILE_SIZE_EXCEEDED);
            }

            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                throw new AppException(ErrorCode.INVALID_FILE_TYPE);
            }

            // public_id cố định theo userId → overwrite lần upload sau, không tạo file rác
            String publicId = "vocaflip/avatars/" + userId;

            Map<String, Object> options = ObjectUtils.asMap(
                    "public_id", publicId,
                    "overwrite", true,
                    "resource_type", "image",
                    "transformation", new Transformation()
                            .width(400)
                            .height(400)
                            .crop("fill")
                            .gravity("face")  // ưu tiên nhận diện khuôn mặt
                            .quality("auto")
            );

            Map<String, Object> result = cloudinary.uploader().upload(file.getBytes(), options);
            String secureUrl = (String) result.get("secure_url");
            log.info("Avatar uploaded successfully for user {}: {}", userId, secureUrl);
            return secureUrl;

        } catch (IOException e) {
            log.error("Error uploading avatar for user {}: {}", userId, e.getMessage());
            throw new AppException(ErrorCode.FILE_UPLOAD_FAILED);
        }
    }

    @Override
    public void deleteAvatar(String userId) {
        try {
            String publicId = "vocaflip/avatars/" + userId;
            cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
            log.info("Avatar deleted successfully for user {}", userId);
        } catch (IOException e) {
            // Không throw exception — thất bại khi xoá không nên block luồng chính
            log.warn("Failed to delete avatar for user {}: {}", userId, e.getMessage());
        }
    }
}