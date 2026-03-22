package com.vocaflipbackend.service;

public interface IRedisOtpService {
    void saveOtp(String email, String otp);

    String getOtp(String email);

    void deleteOtp(String email);
}
