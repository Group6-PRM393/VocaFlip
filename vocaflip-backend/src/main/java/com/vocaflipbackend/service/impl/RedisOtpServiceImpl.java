package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.exception.AppException;
import com.vocaflipbackend.exception.ErrorCode;
import com.vocaflipbackend.repository.UserRepository;
import com.vocaflipbackend.service.IRedisOtpService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
public class RedisOtpServiceImpl implements IRedisOtpService {
    private final StringRedisTemplate redisTemplate;
    private final UserRepository userRepository;


    @Override
    public void saveOtp(String email, String otp) {
        if (userRepository.findByEmail(email).isEmpty()) {
            throw new AppException(ErrorCode.USER_NOT_EXISTED);
        }
        redisTemplate.opsForValue()
                .set("otp:" + email, otp, 5, TimeUnit.MINUTES);
    }

    @Override
    public String getOtp(String email) {
        return redisTemplate.opsForValue()
                .get("otp:" + email);
    }

    @Override
    public void deleteOtp(String email) {
        redisTemplate.delete("otp:" + email);
    }
}
