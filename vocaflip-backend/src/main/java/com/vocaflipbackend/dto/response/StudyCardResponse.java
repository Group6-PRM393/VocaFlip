package com.vocaflipbackend.dto.response;

import com.vocaflipbackend.enums.LearningStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;


// DTO thông tin thẻ trong phiên học. (dữ liệu thẻ gốc + trạng thái tiến độ hiện tại)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StudyCardResponse {

    // Thông tin thẻ
    private String cardId;
    private String front;
    private String back;
    private String phonetic;
    private String exampleSentence;
    private String audioUrl;
    private String imageUrl;
    private Integer orderIndex;

    // Trạng thái tiến độ hiện tại
    private LearningStatus learningStatus;
    private Integer currentInterval;
    private Integer reviewCount;
}
