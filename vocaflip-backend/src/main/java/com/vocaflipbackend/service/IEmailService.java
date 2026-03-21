package com.vocaflipbackend.service;

public interface IEmailService {
    void sendOtpEmail(String email, String otp);
}
