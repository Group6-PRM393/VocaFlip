package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.CategoryRequest;
import com.vocaflipbackend.dto.response.CategoryResponse;
import com.vocaflipbackend.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller quản lý các thao tác với Category (Danh mục)
 */
@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
@Tag(name = "Categories", description = "Quản lý danh mục để phân loại bộ thẻ")
public class CategoryController {

    private final CategoryService categoryService;

    @Operation(summary = "Tạo danh mục mới", description = "Tạo một danh mục mới cho người dùng")
    @PostMapping
    public ResponseEntity<CategoryResponse> createCategory(
            @Parameter(description = "Thông tin danh mục") @Valid @RequestBody CategoryRequest request,
            @Parameter(description = "ID của người dùng") @RequestParam String userId) {
        return ResponseEntity.ok(categoryService.createCategory(request, userId));
    }

    @Operation(summary = "Lấy danh sách danh mục của người dùng", 
               description = "Trả về tất cả danh mục thuộc về một người dùng")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<CategoryResponse>> getCategoriesByUserId(
            @Parameter(description = "ID của người dùng") @PathVariable String userId) {
        return ResponseEntity.ok(categoryService.getCategoriesByUserId(userId));
    }

    @Operation(summary = "Lấy chi tiết danh mục", description = "Trả về thông tin chi tiết của một danh mục")
    @GetMapping("/{id}")
    public ResponseEntity<CategoryResponse> getCategoryById(
            @Parameter(description = "ID của danh mục") @PathVariable String id) {
        return ResponseEntity.ok(categoryService.getCategoryById(id));
    }

    @Operation(summary = "Cập nhật danh mục", description = "Cập nhật thông tin của một danh mục")
    @PutMapping("/{id}")
    public ResponseEntity<CategoryResponse> updateCategory(
            @Parameter(description = "ID của danh mục") @PathVariable String id,
            @Parameter(description = "Thông tin cập nhật") @Valid @RequestBody CategoryRequest request) {
        return ResponseEntity.ok(categoryService.updateCategory(id, request));
    }

    @Operation(summary = "Xóa danh mục", description = "Xóa một danh mục")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCategory(
            @Parameter(description = "ID của danh mục cần xóa") @PathVariable String id) {
        categoryService.deleteCategory(id);
        return ResponseEntity.noContent().build();
    }
}
