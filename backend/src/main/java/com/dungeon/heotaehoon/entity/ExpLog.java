package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "exp_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExpLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id")
    private Student student;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "instructor_id")
    private Instructor instructor;

    @Column(nullable = false)
    private Integer expAmount;

    @Column(nullable = false, length = 50)
    private String expType;

    @Column(nullable = false, length = 50)
    private String sourceType;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;
}
