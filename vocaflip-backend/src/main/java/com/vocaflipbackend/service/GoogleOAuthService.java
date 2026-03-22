package com.vocaflipbackend.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;

public interface GoogleOAuthService {
    /**
     * Verify Google ID Token và trả về payload chứa thông tin user
     *
     * @param idToken ID Token từ Flutter
     * @return GoogleIdToken.Payload chứa email, name, picture, etc.
     * @throws Exception nếu token không hợp lệ
     */
    GoogleIdToken.Payload verifyIdToken(String Token) throws Exception;

    GoogleIdToken.Payload verifyToken(String token) throws Exception;

}
