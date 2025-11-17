package com.dungeon.heotaehoon.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "bosses")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Boss {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "lesson_id")
    @JsonIgnore
    private Lesson lesson;

    @Column(name = "boss_name", nullable = false)
    private String bossName;

    @Column(name = "boss_subtitle")
    private String bossSubtitle;

    @Column(name = "total_hp")
    private Integer totalHp;

    @Column(name = "current_hp")
    private Integer currentHp;

    @Column(name = "is_defeated")
    private Boolean isDefeated;

    @Column(name = "defeat_reward_exp")
    private Integer defeatRewardExp;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (isDefeated == null) {
            isDefeated = false;
        }
        if (totalHp == null) {
            totalHp = 1000;
        }
        if (currentHp == null) {
            currentHp = totalHp;
        }
    }
}
