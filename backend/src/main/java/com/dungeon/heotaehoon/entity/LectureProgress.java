package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "lecture_progress")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LectureProgress {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id")
    private Student student;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lecture_id")
    private AILecture lecture;
    
    @Column(nullable = false)
    private Integer currentSection;
    
    @Column(nullable = false)
    private Integer totalSections;
    
    @Column(nullable = false)
    private Double completionRate;
    
    @Column(nullable = false)
    private Integer comprehensionScore;
    
    private LocalDateTime lastAccessedAt;
    
    @Column(nullable = false)
    private Boolean isCompleted;
    
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(nullable = false)
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (currentSection == null) currentSection = 0;
        if (completionRate == null) completionRate = 0.0;
        if (isCompleted == null) isCompleted = false;
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
