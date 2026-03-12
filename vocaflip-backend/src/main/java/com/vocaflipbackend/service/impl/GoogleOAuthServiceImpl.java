package com.vocaflipbackend.service.impl;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.vocaflipbackend.exception.AppException;
import com.vocaflipbackend.exception.ErrorCode;
import com.vocaflipbackend.service.GoogleOAuthService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
@Slf4j
public class GoogleOAuthServiceImpl implements GoogleOAuthService {

    @Value("${spring.security.oauth2.client.registration.google.client-id}")
    private String googleClientId;

    @Override
    public GoogleIdToken.Payload verifyIdToken(String idToken) throws Exception {
        try {
            // Create verifier with Web Client ID
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(),
                    GsonFactory.getDefaultInstance())
                    // Important: Must set audience is Web Client ID
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();

            // Verify token with Google
            GoogleIdToken googleIdToken = verifier.verify(idToken);

            if (googleIdToken == null) {
                log.error("Invalid Google ID Token");
                throw new AppException(ErrorCode.INVALID_GOOGLE_TOKEN);
            }

            // Get payload have user information
            GoogleIdToken.Payload payload = googleIdToken.getPayload();

            // Log for debug
            log.info("Google token verified for: {}", payload.getEmail());
            log.debug("User ID (sub): {}", payload.getSubject());
            log.debug("Email verified: {}", payload.getEmailVerified());

            return payload;

        } catch (Exception e) {
            log.error("Error verifying Google ID Token: {}", e.getMessage());
            throw new AppException(ErrorCode.INVALID_GOOGLE_TOKEN);
        }
    }

    @Override
    public GoogleIdToken.Payload verifyToken(String token) throws Exception {
        try {
            // Thử verify như ID Token trước (cho mobile)
            return verifyIdToken(token);
        } catch (Exception e) {
            log.info("Not an ID Token, trying as Access Token...");
            return verifyAccessToken(token);
        }
    }

    private GoogleIdToken.Payload verifyAccessToken(String accessToken) throws Exception {
        try {
            // Call Google UserInfo API để verify access token
            String userInfoUrl = "https://www.googleapis.com/oauth2/v1/userinfo?access_token=" + accessToken;

            java.net.URL url = new java.net.URL(userInfoUrl);
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            if (conn.getResponseCode() != 200) {
                throw new AppException(ErrorCode.INVALID_GOOGLE_TOKEN);
            }

            // Parse JSON response
            com.google.gson.JsonParser parser = new com.google.gson.JsonParser();
            com.google.gson.JsonObject userInfo = parser.parse(
                    new java.io.InputStreamReader(conn.getInputStream())
            ).getAsJsonObject();

            // Tạo Payload giả từ userInfo
            GoogleIdToken.Payload payload = new GoogleIdToken.Payload();
            payload.setEmail(userInfo.get("email").getAsString());
            payload.setSubject(userInfo.get("id").getAsString());
            payload.set("name", userInfo.get("name").getAsString());
            payload.set("picture", userInfo.get("picture").getAsString());
            payload.setEmailVerified(userInfo.get("verified_email").getAsBoolean());

            log.info("Access Token verified for: {}", payload.getEmail());
            return payload;

        } catch (Exception e) {
            log.error("Failed to verify access token", e);
            throw new AppException(ErrorCode.INVALID_GOOGLE_TOKEN);
        }
    }
}