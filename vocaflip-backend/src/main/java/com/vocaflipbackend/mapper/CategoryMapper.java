package com.vocaflipbackend.mapper;

import com.vocaflipbackend.dto.request.CategoryRequest;
import com.vocaflipbackend.dto.response.CategoryResponse;
import com.vocaflipbackend.entity.Category;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface CategoryMapper {
    Category toEntity(CategoryRequest request);

    @Mapping(target = "userId", source = "user.id")
    CategoryResponse toResponse(Category category);

    void updateEntity(@MappingTarget Category category, CategoryRequest request);
}
