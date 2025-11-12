package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "worksheet_categories")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WorksheetCategory {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(unique = true, nullable = false, length = 100)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_category_id")
    private WorksheetCategory parentCategory;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(length = 7)
    private String color = "#595048";

    @Column(length = 50)
    private String icon;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
