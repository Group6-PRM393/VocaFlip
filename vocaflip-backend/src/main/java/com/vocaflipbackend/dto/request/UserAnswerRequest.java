package com.vocaflipbackend.dto.request;

import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
public class UserAnswerRequest {
    String questionId;
    String selectedOptionId;
}
