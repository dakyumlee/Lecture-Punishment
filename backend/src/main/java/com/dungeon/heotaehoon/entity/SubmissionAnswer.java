package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "submission_answers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SubmissionAnswer {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "submission_id", nullable = false)
    private StudentSubmission submission;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "question_id", nullable = false)
    private WorksheetQuestion question;

    @Column(name = "student_answer", columnDefinition = "TEXT", nullable = false)
    private String studentAnswer;

    @Column(name = "is_correct")
    private Boolean isCorrect = false;

    @Column(name = "points_earned")
    private Integer pointsEarned = 0;

    @Column(name = "similarity_score", precision = 5, scale = 2)
    private BigDecimal similarityScore;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
