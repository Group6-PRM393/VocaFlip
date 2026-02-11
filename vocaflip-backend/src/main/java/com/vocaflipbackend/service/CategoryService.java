package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.CategoryRequest;
import com.vocaflipbackend.dto.response.CategoryResponse;

import java.util.List;

public interface CategoryService {
    CategoryResponse createCategory(String userId, CategoryRequest request);

    List<CategoryResponse> getAllCategories(String userId);

    CategoryResponse updateCategory(String categoryId, CategoryRequest request);

    void deleteCategory(String categoryId);
}