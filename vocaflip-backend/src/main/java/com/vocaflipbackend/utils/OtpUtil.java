package com.vocaflipbackend.utils;

import org.springframework.stereotype.Component;

import java.security.SecureRandom;
import java.util.Random;

@Component
public class OtpUtil {

    private static final SecureRandom random = new SecureRandom();

    public String generateOtp() {
        int otp = random.nextInt(10000);
        return String.format("%04d", otp);
    }

}