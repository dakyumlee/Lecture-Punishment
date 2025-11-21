package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "ai_lectures")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AILecture {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String lectureName;
    
    @Column(nullable = false)
    private String topic;
    
    @Column(columnDefinition = "TEXT")
    private String syllabus;
    
    @Column(nullable = false)
    private Integer difficulty;
    
    @Column(columnDefinition = "TEXT")
    private String generatedScript;
    
    @Column(nullable = false)
    private String instructorStyle;
    
    @Column(columnDefinition = "TEXT")
    private String baseTranscript;
    
    @Column(columnDefinition = "TEXT")
    private String studentAnalysis;
    
    private Integer estimatedDuration;
    
    @Column(nullable = false)
    private Boolean isActive;
    
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(nullable = false)
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (isActive == null) isActive = true;
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
