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

    @Column(name = "damage_per_correct", nullable = false)
    private Integer damagePerCorrect;

    @Builder.Default
    @Column(name = "is_defeated")
    private Boolean isDefeated = false;

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
        
        if (bossName == null || bossName.isEmpty()) {
            bossName = "보스";
        }
        if (bossSubtitle == null || bossSubtitle.isEmpty()) {
            bossSubtitle = "지식의 수호자";
        }
        if (specialAbility == null) {
            specialAbility = getDefaultSpecialAbility(difficulty);
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

    private String getDefaultSpecialAbility(Integer diff) {
        switch (diff) {
            case 1: return "없음";
            case 2: return "압박: 틀리면 다음 문제 시간 -10초";
            case 3: return "분노 폭발: 3문제 연속 틀리면 HP 10% 회복";
            case 4: return "광폭화: HP 50% 이하 시 데미지 2배 필요";
            case 5: return "허태훈의 진노: 모든 패널티 + HP 30% 회복";
            default: return "없음";
        }
    }

    public String getDifficultyStars() {
        StringBuilder stars = new StringBuilder();
        for (int i = 0; i < difficulty; i++) {
            stars.append("⭐");
        }
        return stars.toString();
    }
    
    public String getName() {
        return bossName != null ? bossName : "알 수 없는 보스";
    }
}
