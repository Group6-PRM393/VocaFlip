package com.vocaflipbackend.service;


import java.math.BigDecimal;

/**
 * Service chứa tính toán SM-2
 */
public interface LearningEngineService {

    /**
     * Kết quả tính toán SM-2 sau khi user đánh giá thẻ.
     */
    record SM2Result(
            int newInterval,           // Khoảng cách ôn tập mới (ngày)
            BigDecimal newEaseFactor,   // Hệ số dễ nhớ mới
            int newReviewCount          // Số lần ôn cộng dồn
    ) {}

    /**
     * Tính toán lịch ôn tập mới dựa trên thuật toán SM-2.
     *
     * @param currentInterval  Khoảng cách ôn tập hiện tại (ngày). 0 nếu là thẻ mới.
     * @param currentEaseFactor Hệ số dễ nhớ hiện tại. Mặc định 2.5.
     * @param currentReviewCount Số lần đã ôn tập.
     * @param grade Đánh giá của user: 0 = Forgot, 1 = Hard, 2 = Good, 3 = Easy.
     * @return SM2Result chứa interval mới, ease factor mới.
     */
    SM2Result calculate(int currentInterval, BigDecimal currentEaseFactor, int currentReviewCount, int grade);
}
