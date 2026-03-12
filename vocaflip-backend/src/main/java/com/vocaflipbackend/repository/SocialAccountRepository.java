package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.SocialAccount;
import com.vocaflipbackend.enums.Provider;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SocialAccountRepository extends JpaRepository<SocialAccount, String> {
    /**
     * Tìm social account theo provider và providerId
     * VD: Tìm user đăng nhập Google với Google ID "123456789"
     */
    Optional<SocialAccount> findByProviderAndProviderId(
            Provider provider,
            String providerId
    );

    /**
     * Tìm social account theo userId và provider
     * Kiểm tra user đã link với provider chưa
     */
    Optional<SocialAccount> findByUserIdAndProvider(
            String userId,
            Provider provider
    );
}
