package com.vocaflipbackend.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UserRegisterRequest {

    @Schema(description = "Tên của user", example = "Demo User")
    @NotBlank(message = "Name is required")
    private String name;

    @Schema(description = "Email của user", example = "demo@demo.com")
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;

    @Schema(description = "Mật khẩu", example = "123456")
    @NotBlank(message = "Password is required")
    private String password;
}
