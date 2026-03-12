package com.vocaflipbackend.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.List;

@Entity
@Table(name = "users")
@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class User extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "password_hash", nullable = true)
    private String passwordHash;

    @Column(nullable = false)
    private String name;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(name = "total_words")
    @Builder.Default
    private Integer totalWords = 0;

    @Column(name = "mastered_words")
    @Builder.Default
    private Integer masteredWords = 0;

    @Column(name = "learning_words")
    @Builder.Default
    private Integer learningWords = 0;

    @Column(name = "streak_days")
    @Builder.Default
    private Integer streakDays = 0;

    @Column(name = "is_confirmed_email")
    @Builder.Default
    private Boolean isConfirmedEmail = false;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<SocialAccount> socialAccounts;

    // Relationships
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Deck> decks;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<StudySession> studySessions;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<QuizAttempt> quizAttempts;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<UserProgress> userProgresses;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Category> categories;
}
