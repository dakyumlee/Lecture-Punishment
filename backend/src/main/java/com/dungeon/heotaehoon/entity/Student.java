package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "students")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Student {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(name = "display_name", nullable = false, length = 100)
    private String displayName;

    @ManyToOne
    @JoinColumn(name = "group_id")
    private StudentGroup group;

    @Column(nullable = false)
    private Integer level = 1;

    @Column(nullable = false)
    private Integer exp = 0;

    @Column(name = "mental_gauge", nullable = false)
    private Integer mentalGauge = 100;

    @Column(name = "total_correct", nullable = false)
    private Integer totalCorrect = 0;

    @Column(name = "total_wrong", nullable = false)
    private Integer totalWrong = 0;

    @Column(name = "character_expression", length = 50)
    private String characterExpression = "normal";

    @Column(name = "character_outfit", length = 50)
    private String characterOutfit = "default";

    @Column(nullable = false)
    private Integer points = 0;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
