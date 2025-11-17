package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "raid_participants")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RaidParticipant {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "raid_session_id", nullable = false)
    private RaidSession raidSession;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @Builder.Default
    @Column(name = "damage_dealt", nullable = false)
    private Integer damageDealt = 0;

    @Builder.Default
    @Column(name = "correct_answers", nullable = false)
    private Integer correctAnswers = 0;

    @Builder.Default
    @Column(name = "wrong_answers", nullable = false)
    private Integer wrongAnswers = 0;

    @Builder.Default
    @Column(name = "has_received_reward")
    private Boolean hasReceivedReward = false;

    @Column(name = "joined_at")
    private LocalDateTime joinedAt;

    @PrePersist
    protected void onCreate() {
        if (joinedAt == null) {
            joinedAt = LocalDateTime.now();
        }
    }
}
