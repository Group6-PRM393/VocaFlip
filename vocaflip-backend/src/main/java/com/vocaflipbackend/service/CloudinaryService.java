package com.vocaflipbackend.service;

import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

public interface CloudinaryService {

    /**
     * Upload file lên Cloudinary.
     *
     * @param file   file cần upload
     * @param folder thư mục lưu trữ trên Cloudinary
     * @return Map chứa thông tin file đã upload (url, public_id, ...)
     */
    Map<String, Object> uploadFile(MultipartFile file, String folder);

    /**
     * Upload image với các tùy chọn resize.
     *
     * @param file   file ảnh cần upload
     * @param folder thư mục lưu trữ
     * @param width  chiều rộng mong muốn
     * @param height chiều cao mong muốn
     * @return Map chứa thông tin file đã upload
     */
    Map<String, Object> uploadImage(MultipartFile file, String folder, int width, int height);

    /**
     * Upload ảnh đại diện cho user.
     * Tự động crop 400×400, ưu tiên nhận diện khuôn mặt.
     * Dùng public_id cố định theo userId → overwrite lần upload sau,
     * tránh tích lũy file rác trên Cloudinary.
     *
     * @param file   file ảnh avatar
     * @param userId ID của user (dùng làm public_id)
     * @return secure_url của ảnh sau khi upload
     */
    String uploadAvatar(MultipartFile file, String userId);

    /**
     * Xoá ảnh đại diện của user khỏi Cloudinary.
     *
     * @param userId ID của user
     */
    void deleteAvatar(String userId);
}