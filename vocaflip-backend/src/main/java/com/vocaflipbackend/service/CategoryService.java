package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.CategoryRequest;
import com.vocaflipbackend.dto.response.CategoryResponse;

import java.util.List;

public interface CategoryService {
    CategoryResponse createCategory(CategoryRequest request, String userId);
    List<CategoryResponse> getCategoriesByUserId(String userId);
    CategoryResponse getCategoryById(String id);
    CategoryResponse updateCategory(String id, CategoryRequest request);
    void deleteCategory(String id);
}
