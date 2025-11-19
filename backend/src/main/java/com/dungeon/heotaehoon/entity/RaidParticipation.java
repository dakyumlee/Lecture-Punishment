package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "raid_participations")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RaidParticipation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "raid_id", nullable = false)
    private Raid raid;

    @ManyToOne
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @Column(name = "damage_dealt")
    private Integer damageDealt;

    @Column(name = "questions_answered")
    private Integer questionsAnswered;

    @Column(name = "correct_answers")
    private Integer correctAnswers;

    @Column(name = "joined_at")
    private LocalDateTime joinedAt;

    @PrePersist
    protected void onCreate() {
        joinedAt = LocalDateTime.now();
        if (damageDealt == null) {
            damageDealt = 0;
        }
        if (questionsAnswered == null) {
            questionsAnswered = 0;
        }
        if (correctAnswers == null) {
            correctAnswers = 0;
        }
    }
}
