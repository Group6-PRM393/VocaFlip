package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.config.CustomUserDetails;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

/**
 * Custom UserDetailsService - Load user từ database cho Spring Security.
 * Trả về CustomUserDetails chứa đầy đủ thông tin User entity (bao gồm userId).
 */
@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

  private final UserRepository userRepository;

  @Override
  public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
    User user = userRepository.findByEmail(email)
        .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));

    // Trả về CustomUserDetails chứa User entity
    // -> SecurityContext sẽ lưu trữ userId, email, name,...
    return new CustomUserDetails(user);
  }
}

