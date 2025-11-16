package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "student_submissions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudentSubmission {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @ManyToOne
    @JoinColumn(name = "worksheet_id", nullable = false)
    private Worksheet worksheet;

    @Column(name = "score")
    private Integer score;

    @Column(name = "correct_count")
    private Integer correctCount;

    @Column(name = "total_questions")
    private Integer totalQuestions;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (submittedAt == null) {
            submittedAt = LocalDateTime.now();
        }
        if (score == null) {
            score = 0;
        }
        if (correctCount == null) {
            correctCount = 0;
        }
        if (totalQuestions == null) {
            totalQuestions = 0;
        }
    }
}
