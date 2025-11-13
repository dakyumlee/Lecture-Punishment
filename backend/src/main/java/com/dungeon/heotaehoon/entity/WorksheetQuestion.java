package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "worksheet_questions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WorksheetQuestion {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "worksheet_id", nullable = false)
    private PdfWorksheet worksheet;

    @Column(name = "question_number", nullable = false)
    private Integer questionNumber;

    @Column(name = "question_type", nullable = false, length = 20)
    private String questionType;

    @Column(name = "question_text", columnDefinition = "TEXT", nullable = false)
    private String questionText;

    @Column(name = "correct_answer", columnDefinition = "TEXT", nullable = false)
    private String correctAnswer;

    @Column(name = "option_a", columnDefinition = "TEXT")
    private String optionA;

    @Column(name = "option_b", columnDefinition = "TEXT")
    private String optionB;

    @Column(name = "option_c", columnDefinition = "TEXT")
    private String optionC;

    @Column(name = "option_d", columnDefinition = "TEXT")
    private String optionD;

    @Column(nullable = false)
    private Integer points = 10;

    @Column(name = "allow_partial")
    private Boolean allowPartial = false;

    @Column(name = "similarity_threshold", precision = 3, scale = 2)
    private BigDecimal similarityThreshold = new BigDecimal("0.85");

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
