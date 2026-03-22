package com.vocaflipbackend.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class LearningTrajectoryPointResponse {
    private String date;
    private int value;
}
