package com.vocaflipbackend.config;

import jakarta.annotation.Nonnull;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * JWT Authentication Filter - Filter mỗi request để authenticate user thông qua
 * JWT token
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

  private final JwtUtils jwtUtils;
  private final UserDetailsService userDetailsService;

  @Override
  protected void doFilterInternal(
      @Nonnull HttpServletRequest request,
      @Nonnull HttpServletResponse response,
      @Nonnull FilterChain filterChain) throws ServletException, IOException {

    // Extract JWT token từ Authorization header
    final String authHeader = request.getHeader("Authorization");
    final String jwt;
    final String userEmail;

    // Kiểm tra header có tồn tại và đúng format không
    if (authHeader == null || !authHeader.startsWith("Bearer ")) {
      filterChain.doFilter(request, response);
      return;
    }

    // Extract token (bỏ prefix "Bearer ")
    jwt = authHeader.substring(7);

    try {
      // Extract user email từ token
      userEmail = jwtUtils.extractUsername(jwt);

      // Nếu email tồn tại và chưa được authenticate
      if (userEmail != null && SecurityContextHolder.getContext().getAuthentication() == null) {
        // Load user details từ database
        UserDetails userDetails = this.userDetailsService.loadUserByUsername(userEmail);

        // Validate token
        if (jwtUtils.validateToken(jwt, userDetails)) {
          // Tạo authentication object
          UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
              userDetails,
              null,
              userDetails.getAuthorities());

          authToken.setDetails(
              new WebAuthenticationDetailsSource().buildDetails(request));

          // Set authentication vào SecurityContext
          SecurityContextHolder.getContext().setAuthentication(authToken);
        }
      }
    } catch (Exception e) {
      // Log lỗi nếu cần
      logger.error("Cannot set user authentication: {}", e);
    }

    filterChain.doFilter(request, response);
  }
}
