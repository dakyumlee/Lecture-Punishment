package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "raid_sessions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RaidSession {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "raid_boss_id", nullable = false)
    private RaidBoss raidBoss;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "group_id")
    private StudentGroup group;

    @Column(name = "session_status", length = 50)
    private String sessionStatus;

    @Column(name = "current_hp", nullable = false)
    private Integer currentHp;

    @Column(name = "total_damage_dealt", nullable = false)
    private Integer totalDamageDealt;

    @Column(name = "participant_count", nullable = false)
    private Integer participantCount;

    @Column(name = "started_at")
    private LocalDateTime startedAt;

    @Column(name = "ended_at")
    private LocalDateTime endedAt;

    @Column(name = "deadline")
    private LocalDateTime deadline;

    @Builder.Default
    @Column(name = "is_success")
    private Boolean isSuccess = false;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (sessionStatus == null) {
            sessionStatus = "waiting";
        }
    }
}
