package com.dungeon.heotaehoon.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

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

    @OneToMany(mappedBy = "boss", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private List<Quiz> quizzes;

    @Column(name = "boss_name", nullable = false)
    private String bossName;

    @Column(name = "boss_subtitle")
    private String bossSubtitle;

    @Builder.Default
    @Column(name = "difficulty", nullable = false)
    private Integer difficulty = 3;

    @Column(name = "special_ability")
    private String specialAbility;

    @Column(name = "total_hp")
    private Integer totalHp;

    @Column(name = "current_hp")
    private Integer currentHp;

    @Builder.Default
    @Column(name = "damage_per_correct", nullable = false)
    private Integer damagePerCorrect = 200;

    @Column(name = "is_defeated")
    private Boolean isDefeated;

    @Column(name = "defeat_reward_exp")
    private Integer defeatRewardExp;

    @Column(name = "defeat_reward_points")
    private Integer defeatRewardPoints;

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
        if (difficulty == null) {
            difficulty = 3;
        }
        
        if (totalHp == null) {
            totalHp = calculateHpByDifficulty(difficulty);
        }
        if (currentHp == null) {
            currentHp = totalHp;
        }
        if (damagePerCorrect == null) {
            damagePerCorrect = calculateDamageByDifficulty(difficulty);
        }
        if (defeatRewardExp == null) {
            defeatRewardExp = calculateExpByDifficulty(difficulty);
        }
        if (defeatRewardPoints == null) {
            defeatRewardPoints = calculatePointsByDifficulty(difficulty);
        }
    }

    private Integer calculateHpByDifficulty(Integer diff) {
        switch (diff) {
            case 1: return 500;
            case 2: return 1000;
            case 3: return 1500;
            case 4: return 2500;
            case 5: return 5000;
            default: return 1000;
        }
    }

    private Integer calculateDamageByDifficulty(Integer diff) {
        switch (diff) {
            case 1: return 100;
            case 2: return 200;
            case 3: return 300;
            case 4: return 500;
            case 5: return 1000;
            default: return 200;
        }
    }

    private Integer calculateExpByDifficulty(Integer diff) {
        switch (diff) {
            case 1: return 10;
            case 2: return 30;
            case 3: return 50;
            case 4: return 80;
            case 5: return 100;
            default: return 30;
        }
    }

    private Integer calculatePointsByDifficulty(Integer diff) {
        switch (diff) {
            case 1: return 50;
            case 2: return 150;
            case 3: return 250;
            case 4: return 400;
            case 5: return 500;
            default: return 150;
        }
    }

    public String getDifficultyStars() {
        StringBuilder stars = new StringBuilder();
        for (int i = 0; i < difficulty; i++) {
            stars.append("⭐");
        }
        return stars.toString();
    }
}
