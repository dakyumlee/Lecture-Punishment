package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "soul_fragments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SoulFragment {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @ManyToOne
    @JoinColumn(name = "multiverse_instructor_id", nullable = false)
    private MultiverseInstructor multiverseInstructor;

    @Column(name = "fragment_name", length = 100)
    private String fragmentName;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "obtained_at")
    private LocalDateTime obtainedAt;

    @PrePersist
    protected void onObtain() {
        obtainedAt = LocalDateTime.now();
    }
}
