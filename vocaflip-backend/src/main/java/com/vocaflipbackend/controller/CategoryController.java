package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.CategoryRequest;
import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.CategoryResponse;
import com.vocaflipbackend.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
@Tag(name = "Category Controller", description = "Quản lý danh mục (Icon, Màu sắc, CRUD)")
public class CategoryController {

    private final CategoryService categoryService;

    @PostMapping
    @Operation(summary = "Tạo danh mục mới")
    public ApiResponse<CategoryResponse> createCategory(
            @RequestParam String userId,
            @RequestBody @Valid CategoryRequest request
    ) {
        CategoryResponse response = categoryService.createCategory(userId, request);

        return ApiResponse.<CategoryResponse>builder()
                .code(1000)
                .result(response)
                .message("Category created successfully")
                .build();
    }

    @GetMapping
    @Operation(summary = "Lấy danh sách danh mục của User")
    public ApiResponse<List<CategoryResponse>> getAllCategories(
            @RequestParam String userId
    ) {
        List<CategoryResponse> response = categoryService.getAllCategories(userId);

        return ApiResponse.<List<CategoryResponse>>builder()
                .code(1000)
                .result(response)
                .message("Categories fetched successfully")
                .build();
    }

    @PutMapping("/{id}")
    @Operation(summary = "Cập nhật danh mục (Tên, Icon, Màu)")
    public ApiResponse<CategoryResponse> updateCategory(
            @PathVariable String id,
            @RequestBody @Valid CategoryRequest request
    ) {
        CategoryResponse response = categoryService.updateCategory(id, request);

        return ApiResponse.<CategoryResponse>builder()
                .code(1000)
                .result(response)
                .message("Category updated successfully")
                .build();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Xóa danh mục (Soft Delete)")
    public ApiResponse<Void> deleteCategory(@PathVariable String id) {
        categoryService.deleteCategory(id);

        return ApiResponse.<Void>builder()
                .code(1000)
                .message("Category deleted successfully")
                .build();
    }
}