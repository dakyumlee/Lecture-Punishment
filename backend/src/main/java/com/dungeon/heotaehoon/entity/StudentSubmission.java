package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

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

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "worksheet_id", nullable = false)
    private PdfWorksheet worksheet;

    @Column(name = "submission_date")
    private LocalDateTime submissionDate;

    @Column(name = "total_score")
    private Integer totalScore = 0;

    @Column(name = "max_score")
    private Integer maxScore = 0;

    @Column(precision = 5, scale = 2)
    private BigDecimal percentage = BigDecimal.ZERO;

    @Column(name = "is_graded")
    private Boolean isGraded = false;

    @Column(name = "graded_at")
    private LocalDateTime gradedAt;

    @OneToMany(mappedBy = "submission", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<SubmissionAnswer> answers;

    @PrePersist
    protected void onCreate() {
        if (submissionDate == null) {
            submissionDate = LocalDateTime.now();
        }
    }
}
