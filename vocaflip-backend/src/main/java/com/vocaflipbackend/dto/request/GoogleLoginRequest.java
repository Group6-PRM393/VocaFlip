package com.vocaflipbackend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GoogleLoginRequest {

    /**
     * Google ID Token is returned from Google Sign-In
     * Token will be verified with Google get user information
     */
    @NotBlank(message = "ID Token is required")
    private String idToken;
}
