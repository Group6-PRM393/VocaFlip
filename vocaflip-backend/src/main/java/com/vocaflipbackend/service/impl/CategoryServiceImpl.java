package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.request.CategoryRequest;
import com.vocaflipbackend.dto.response.CategoryResponse;
import com.vocaflipbackend.entity.Category;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.mapper.CategoryMapper;
import com.vocaflipbackend.repository.CategoryRepository;
import com.vocaflipbackend.repository.UserRepository;
import com.vocaflipbackend.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;
    private final CategoryMapper categoryMapper;

    @Override
    public CategoryResponse createCategory(CategoryRequest request, String userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Category category = categoryMapper.toEntity(request);
        category.setUser(user);

        Category savedCategory = categoryRepository.save(category);
        return categoryMapper.toResponse(savedCategory);
    }

    @Override
    public List<CategoryResponse> getCategoriesByUserId(String userId) {
        // Find categories that are not removed
        return categoryRepository.findByUserIdAndIsRemovedFalse(userId).stream()
                .map(categoryMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public CategoryResponse getCategoryById(String id) {
        Category category = categoryRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Category not found"));
        return categoryMapper.toResponse(category);
    }

    @Override
    public CategoryResponse updateCategory(String id, CategoryRequest request) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));

        // Use mapper to update fields
        categoryMapper.updateEntity(category, request);
        
        Category updatedCategory = categoryRepository.save(category);
        return categoryMapper.toResponse(updatedCategory);
    }

    @Override
    public void deleteCategory(String id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));

        // Manual soft delete
        category.setRemoved(true);
        categoryRepository.save(category);
    }
}
