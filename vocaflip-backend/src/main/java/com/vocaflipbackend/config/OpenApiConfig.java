package com.vocaflipbackend.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Cấu hình OpenAPI/Swagger cho VocaFlip Backend
 * Swagger UI có thể truy cập tại: /swagger-ui.html
 * OpenAPI JSON spec có thể truy cập tại: /v3/api-docs
 * 
 * Để test API với JWT:
 * 1. Đăng nhập qua /api/auth/login
 * 2. Copy accessToken từ response
 * 3. Click nút "Authorize" trên Swagger UI
 * 4. Nhập token (không cần thêm 'Bearer')
 * 5. Tất cả API calls sẽ tự động có Authorization header
 */
@Configuration
public class OpenApiConfig {

        @Value("${server.port:8080}")
        private String serverPort;
        @Value("${URL_DEPLOY}")
        private String urlDeploy;

        @Bean
        public OpenAPI vocaFlipOpenAPI() {
                // Tên của security scheme
                final String securitySchemeName = "Bearer Authentication";

                // Cấu hình thông tin API
                Info info = new Info()
                                .title("VocaFlip API")
                                .version("1.0.0")
                                .description("API documentation cho ứng dụng VocaFlip - Flashcard Learning Platform")
                                .contact(new Contact()
                                                .name("VocaFlip Team")
                                                .email("support@vocaflip.com"))
                                .license(new License()
                                                .name("MIT License")
                                                .url("https://opensource.org/licenses/MIT"));

                // Cấu hình server URLs
                Server devServer = new Server()
                                .url("http://localhost:" + serverPort)
                                .description("Development Server");

                Server prodServer = new Server()
                                .url(urlDeploy)
                                .description("Production Server");

                return new OpenAPI()
                                .info(info)
                                .servers(List.of(devServer, prodServer))
                                // Thêm Security Requirement - áp dụng cho TẤT CẢ endpoints
                                .addSecurityItem(new SecurityRequirement()
                                                .addList(securitySchemeName))
                                // Định nghĩa Security Scheme - JWT Bearer Token
                                .components(new Components()
                                                .addSecuritySchemes(securitySchemeName, new SecurityScheme()
                                                                .name(securitySchemeName)
                                                                .type(SecurityScheme.Type.HTTP)
                                                                .scheme("bearer")
                                                                .bearerFormat("JWT")
                                                                .description("Nhập Access Token vào đây. Token sẽ tự động được thêm vào header: Authorization: Bearer {token}")));
        }
}
