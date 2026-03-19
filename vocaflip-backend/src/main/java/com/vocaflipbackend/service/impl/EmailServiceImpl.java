package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.service.IEmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailServiceImpl implements IEmailService {
    private final JavaMailSender mailSender;

    @Override
    public void sendOtpEmail(String email, String otp) {

        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(email);
        message.setSubject("[Vocaflip] Your OTP Verification Code");
        message.setText("""
Hello,

Your OTP verification code for Vocaflip is:

""" + otp + """

This code will expire in 5 minutes.

If you did not request this code, please ignore this email.

Best regards,
Vocaflip Team
""");

        mailSender.send(message);
    }

}
