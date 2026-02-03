package com.vocaflipbackend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * DTO chứa kết quả phân trang generic
 * Sử dụng cho tất cả các API trả về danh sách có phân trang
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PageResponse<T> {
    // Danh sách dữ liệu của trang hiện tại
    private List<T> content;
    
    // Số trang hiện tại (0-indexed)
    private int page;
    
    // Kích thước mỗi trang
    private int pageSize;
    
    // Tổng số phần tử
    private long totalElements;
    
    // Tổng số trang
    private int totalPages;
    
    // Kiểm tra có phải trang cuối không
    private boolean last;
    
    // Kiểm tra có phải trang đầu không
    private boolean first;
}
