package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "rage_dialogues")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RageDialogue {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "instructor_id")
    private Instructor instructor;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String dialogueText;

    @Column(nullable = false, length = 50)
    private String dialogueType;

    @Column(nullable = false)
    private Integer intensityLevel = 1;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;
}
