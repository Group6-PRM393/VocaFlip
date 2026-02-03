package com.vocaflipbackend.service;

import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

public interface CloudinaryService {

    /**
     * Upload file lên Cloudinary
     *
     * @param file   file cần upload
     * @param folder thư mục lưu trữ trên Cloudinary
     * @return Map chứa thông tin file đã upload (url, public_id, ...)
     */
    Map<String, Object> uploadFile(MultipartFile file, String folder);


    /**
     * Upload image với các tùy chọn resize
     *
     * @param file   file ảnh cần upload
     * @param folder thư mục lưu trữ
     * @param width  chiều rộng mong muốn
     * @param height chiều cao mong muốn
     * @return Map chứa thông tin file đã upload
     */
    Map<String, Object> uploadImage(MultipartFile file, String folder, int width, int height);
}
