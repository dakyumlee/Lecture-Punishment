package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "raid_bosses")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RaidBoss {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(name = "boss_name", nullable = false, length = 100)
    private String bossName;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "total_hp", nullable = false)
    private Integer totalHp;

    @Column(name = "current_hp", nullable = false)
    private Integer currentHp;

    @Column(name = "min_participants", nullable = false)
    private Integer minParticipants;

    @Column(name = "time_limit_minutes", nullable = false)
    private Integer timeLimitMinutes;

    @Column(name = "damage_per_correct", nullable = false)
    private Integer damagePerCorrect;

    @Column(name = "reward_exp", nullable = false)
    private Integer rewardExp;

    @Column(name = "reward_points", nullable = false)
    private Integer rewardPoints;

    @Column(name = "penalty_description", columnDefinition = "TEXT")
    private String penaltyDescription;

    @Builder.Default
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Builder.Default
    @Column(name = "is_defeated", nullable = false)
    private Boolean isDefeated = false;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
