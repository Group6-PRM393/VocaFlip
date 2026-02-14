package com.vocaflipbackend.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

/**
 * JWT Utility class - Xử lý tạo, validate và extract thông tin từ JWT tokens
 */
@Component
public class JwtUtils {

  @Value("${jwt.secret}")
  private String jwtSecret;

  @Value("${jwt.access-token-expiration}")
  private long accessTokenExpiration;

  @Value("${jwt.refresh-token-expiration}")
  private long refreshTokenExpiration;

  /**
   * Extract username (email) từ token
   */
  public String extractUsername(String token) {
    return extractClaim(token, Claims::getSubject);
  }

  /**
   * Extract expiration date từ token
   */
  public Date extractExpiration(String token) {
    return extractClaim(token, Claims::getExpiration);
  }

  /**
   * Extract một claim cụ thể từ token
   */
  public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
    final Claims claims = extractAllClaims(token);
    return claimsResolver.apply(claims);
  }

  /**
   * Extract tất cả claims từ token
   */
  private Claims extractAllClaims(String token) {
    return Jwts
        .parser()
        .verifyWith((javax.crypto.SecretKey) getSigningKey())
        .build()
        .parseSignedClaims(token)
        .getPayload();
  }

  /**
   * Kiểm tra token đã hết hạn chưa
   */
  private Boolean isTokenExpired(String token) {
    return extractExpiration(token).before(new Date());
  }

  /**
   * Validate token với UserDetails
   */
  public Boolean validateToken(String token, UserDetails userDetails) {
    final String username = extractUsername(token);
    return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
  }

  /**
   * Generate access token cho user
   */
  public String generateAccessToken(UserDetails userDetails) {
    return createToken(new HashMap<>(), userDetails.getUsername(), accessTokenExpiration);
  }

  /**
   * Generate refresh token cho user
   */
  public String generateRefreshToken(UserDetails userDetails) {
    return createToken(new HashMap<>(), userDetails.getUsername(), refreshTokenExpiration);
  }

  /**
   * Tạo token với claims, subject và expiration time
   */
  private String createToken(Map<String, Object> claims, String subject, long expiration) {
    return Jwts
        .builder()
        .setClaims(claims)
        .setSubject(subject)
        .setIssuedAt(new Date(System.currentTimeMillis()))
        .setExpiration(new Date(System.currentTimeMillis() + expiration))
        .signWith(getSigningKey(), SignatureAlgorithm.HS256)
        .compact();
  }

  /**
   * Get signing key từ secret
   */
  private Key getSigningKey() {
    byte[] keyBytes = Decoders.BASE64.decode(jwtSecret);
    return Keys.hmacShaKeyFor(keyBytes);
  }

  /**
   * Get access token expiration time (in milliseconds)
   */
  public long getAccessTokenExpiration() {
    return accessTokenExpiration;
  }

  /**
   * Get refresh token expiration time (in milliseconds)
   */
  public long getRefreshTokenExpiration() {
    return refreshTokenExpiration;
  }
}
