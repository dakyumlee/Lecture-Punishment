package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "quiz_attempts")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id")
    private Student student;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_id")
    private Quiz quiz;

    @Column(nullable = false, length = 1)
    private String selectedAnswer;

    @Column(nullable = false)
    private Boolean isCorrect;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime attemptTime;

    @Builder.Default
    @Column(nullable = false)
    private Boolean rageTriggered = false;

    @Builder.Default
    @Column(nullable = false)
    private Integer comboCount = 0;
}
