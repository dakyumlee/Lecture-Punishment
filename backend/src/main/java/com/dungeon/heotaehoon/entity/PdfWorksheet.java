package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "pdf_worksheets")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PdfWorksheet {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "instructor_id")
    private Instructor instructor;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, length = 100)
    private String subject;

    @Column(nullable = false, length = 100)
    private String category;

    @Column(name = "difficulty_level")
    private Integer difficultyLevel = 1;

    @Column(name = "pdf_url", length = 500)
    private String pdfUrl;

    @Column(name = "total_questions")
    private Integer totalQuestions = 0;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @OneToMany(mappedBy = "worksheet", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<WorksheetQuestion> questions;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (updatedAt == null) {
            updatedAt = LocalDateTime.now();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
