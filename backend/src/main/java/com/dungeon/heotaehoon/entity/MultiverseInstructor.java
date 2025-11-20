package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "multiverse_instructors")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MultiverseInstructor {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(name = "universe_type", nullable = false, length = 50)
    private String universeType;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "personality_trait", length = 100)
    private String personalityTrait;

    @Column(name = "difficulty_multiplier")
    private Double difficultyMultiplier;

    @Column(name = "reward_multiplier")
    private Double rewardMultiplier;

    @Column(name = "special_ability", columnDefinition = "TEXT")
    private String specialAbility;

    @Builder.Default
    @Column(name = "is_unlocked")
    private Boolean isUnlocked = false;

    @Column(name = "unlock_condition", columnDefinition = "TEXT")
    private String unlockCondition;

    @Column(name = "avatar_emoji", length = 10)
    private String avatarEmoji;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
