package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
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

    @Column(nullable = false, length = 50)
    private String username;

    @Column(name = "display_name", nullable = false, length = 100)
    private String displayName;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(name = "phone_number", length = 20)
    private String phoneNumber;

    @Column(name = "student_id_number", length = 50)
    private String studentIdNumber;

    @Builder.Default
    @Column(name = "is_profile_complete", nullable = false, columnDefinition = "boolean default false")
    private Boolean isProfileComplete = false;

    @ManyToOne
    @JoinColumn(name = "group_id")
    private StudentGroup group;

    @Builder.Default
    @Column(nullable = false)
    private Integer level = 1;

    @Builder.Default
    @Column(nullable = false)
    private Integer exp = 0;

    @Builder.Default
    @Column(nullable = false)
    private Integer points = 0;

    @Column(name = "character_expression", length = 10)
    private String characterExpression = "😊";

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
