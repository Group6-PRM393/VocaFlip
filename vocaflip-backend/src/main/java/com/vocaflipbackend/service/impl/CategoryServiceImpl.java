package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.request.CategoryRequest;
import com.vocaflipbackend.dto.response.CategoryResponse;
import com.vocaflipbackend.entity.Category;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.repository.CategoryRepository;
import com.vocaflipbackend.repository.UserRepository;
import com.vocaflipbackend.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public CategoryResponse createCategory(String userId, CategoryRequest request) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Category category = Category.builder()
                .categoryName(request.getCategoryName())
                .iconCode(request.getIconCode())
                .colorHex(request.getColorHex())
                .user(user)
                .isRemoved(false)
                .build();

        Category savedCategory = categoryRepository.save(category);
        return mapToResponse(savedCategory);
    }

    @Override
    public List<CategoryResponse> getAllCategories(String userId) {
        List<Category> categories = categoryRepository.findByUserIdAndIsRemovedFalse(userId);

        return categories.stream()
                .filter(c -> !c.isRemoved())
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public CategoryResponse updateCategory(String categoryId, CategoryRequest request) {
        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new RuntimeException("Category not found"));

        category.setCategoryName(request.getCategoryName());

        if (request.getIconCode() != null) category.setIconCode(request.getIconCode());
        if (request.getColorHex() != null) category.setColorHex(request.getColorHex());

        Category updatedCategory = categoryRepository.save(category);
        return mapToResponse(updatedCategory);
    }

    @Override
    @Transactional
    public void deleteCategory(String categoryId) {
        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new RuntimeException("Category not found"));

        category.setRemoved(true);
        categoryRepository.save(category);
    }

    private CategoryResponse mapToResponse(Category category) {
        int activeDeckCount = 0;
        if (category.getDecks() != null) {
            activeDeckCount = (int) category.getDecks().stream()
                    .filter(d -> !d.isRemoved())
                    .count();
        }

        return CategoryResponse.builder()
                .id(category.getId())
                .categoryName(category.getCategoryName())
                .iconCode(category.getIconCode())
                .colorHex(category.getColorHex())
                .deckCount(activeDeckCount)
                .build();
    }
}