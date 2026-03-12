package com.vocaflipbackend.entity;

import com.vocaflipbackend.enums.Provider;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "social_account")
@Data
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class SocialAccount {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Enumerated(EnumType.STRING)
    private Provider provider; // Enum: GOOGLE, FACEBOOK, GITHUB

    @Column(name = "provider_id", nullable = false)
    private String providerId; // 'sub' (Subject ID) from Google

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}
