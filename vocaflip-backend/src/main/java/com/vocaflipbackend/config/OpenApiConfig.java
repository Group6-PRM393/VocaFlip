package com.vocaflipbackend.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Cấu hình OpenAPI/Swagger cho VocaFlip Backend
 * Swagger UI có thể truy cập tại: /swagger-ui.html
 * OpenAPI JSON spec có thể truy cập tại: /v3/api-docs
 */
@Configuration
public class OpenApiConfig {

    @Value("${server.port:8080}")
    private String serverPort;
    @Value("${URL_DEPLOY}")
    private String urlDeploy;

    @Bean
    public OpenAPI vocaFlipOpenAPI() {
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
                .servers(List.of(devServer, prodServer));
    }
}
