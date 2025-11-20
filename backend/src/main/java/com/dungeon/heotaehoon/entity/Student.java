package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

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

    @Column(length = 255)
    private String password;

    @Column(name = "display_name", nullable = false, length = 100)
    private String displayName;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(name = "phone_number", length = 20)
    private String phoneNumber;

    @Column(name = "student_id_number", length = 50)
    private String studentIdNumber;

    @Builder.Default
    @Column(name = "is_profile_complete", nullable = false)
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

    @Builder.Default
    @Column(name = "total_correct", nullable = false)
    private Integer totalCorrect = 0;

    @Builder.Default
    @Column(name = "total_wrong", nullable = false)
    private Integer totalWrong = 0;

    @Builder.Default
    @Column(name = "mental_gauge", nullable = false)
    private Integer mentalGauge = 100;

    @Builder.Default
    @Column(name = "character_expression", length = 10)
    private String characterExpression = "😊";

    @Column(name = "character_outfit", length = 255)
    private String characterOutfit;

    @ElementCollection
    @CollectionTable(name = "student_purchased_items", joinColumns = @JoinColumn(name = "student_id"))
    @Column(name = "item_id")
    @Builder.Default
    private List<String> purchasedItems = new ArrayList<>();

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (purchasedItems == null) {
            purchasedItems = new ArrayList<>();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
