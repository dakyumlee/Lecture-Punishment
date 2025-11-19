package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "raids")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Raid {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "raid_name", nullable = false)
    private String raidName;

    @Column(name = "boss_name", nullable = false)
    private String bossName;

    @Column(name = "total_hp", nullable = false)
    private Integer totalHp;

    @Column(name = "current_hp", nullable = false)
    private Integer currentHp;

    @Column(name = "required_participants", nullable = false)
    private Integer requiredParticipants;

    @Column(name = "time_limit_minutes", nullable = false)
    private Integer timeLimitMinutes;

    @Column(name = "status", length = 20)
    private String status;

    @Column(name = "start_time")
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "reward_points")
    private Integer rewardPoints;

    @Column(name = "reward_exp")
    private Integer rewardExp;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (status == null) {
            status = "waiting";
        }
        if (currentHp == null) {
            currentHp = totalHp;
        }
    }
}
