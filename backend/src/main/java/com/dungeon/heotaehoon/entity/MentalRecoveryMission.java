package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "mental_recovery_missions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MentalRecoveryMission {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(name = "mission_type", nullable = false, length = 50)
    private String missionType;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "recovery_amount", nullable = false)
    private Integer recoveryAmount;

    @Column(name = "difficulty_level")
    private Integer difficultyLevel;

    @Column(name = "question_text", columnDefinition = "TEXT")
    private String questionText;

    @Column(name = "correct_answer", length = 255)
    private String correctAnswer;

    @Builder.Default
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
