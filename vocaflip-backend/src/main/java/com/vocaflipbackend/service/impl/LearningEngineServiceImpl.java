package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.service.LearningEngineService;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;


@Service
public class LearningEngineServiceImpl implements LearningEngineService {

    // Ease Factor tối thiểu (không giảm dưới ngưỡng này)
    private static final BigDecimal MIN_EASE_FACTOR = new BigDecimal("1.30");

    // Ease Factor mặc định cho thẻ mới
    private static final BigDecimal DEFAULT_EASE_FACTOR = new BigDecimal("2.50");

    @Override
    public SM2Result calculate(int currentInterval, BigDecimal currentEaseFactor, int currentReviewCount, int grade) {

        // Nếu EF chưa được set (thẻ mới), dùng giá trị mặc định
        if (currentEaseFactor == null || currentEaseFactor.compareTo(BigDecimal.ZERO) == 0) {
            currentEaseFactor = DEFAULT_EASE_FACTOR;
        }

        // Bước 1: Tính Ease Factor mới
        // Mapping grade 0-3 sang SM-2 gốc (0-5): grade * 5/3
        double mappedGrade = grade * 5.0 / 3.0;
        double efChange = 0.1 - (5.0 - mappedGrade) * (0.08 + (5.0 - mappedGrade) * 0.02);
        BigDecimal newEaseFactor = currentEaseFactor.add(BigDecimal.valueOf(efChange))
                .setScale(2, RoundingMode.HALF_UP);

        // Đảm bảo EF không giảm dưới mức tối thiểu
        if (newEaseFactor.compareTo(MIN_EASE_FACTOR) < 0) {
            newEaseFactor = MIN_EASE_FACTOR;
        }

        // Tính Interval mới
        int newInterval;
        int newReviewCount = currentReviewCount + 1;

        if (grade < 2) {
            // Forgot (0) hoặc Hard (1): Reset interval, bắt đầu lại
            newInterval = 1;
            newReviewCount = 1; // Reset lại số lần ôn
        } else {
            // Good (2) hoặc Easy (3): Tăng interval
            if (currentReviewCount == 0) {
                // Lần đầu tiên học thẻ này
                newInterval = 1;
            } else if (currentReviewCount == 1) {
                // Lần thứ 2
                newInterval = 6;
            } else {
                // Lần thứ 3 trở đi: interval * EF
                newInterval = BigDecimal.valueOf(currentInterval)
                        .multiply(newEaseFactor)
                        .setScale(0, RoundingMode.CEILING)
                        .intValue();
            }

            //  Easy: nhân thêm 1.3
            if (grade == 3) {
                newInterval = (int) Math.ceil(newInterval * 1.3);
            }
        }

        return new SM2Result(newInterval, newEaseFactor, newReviewCount);
    }
}
