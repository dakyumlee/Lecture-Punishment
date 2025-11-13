package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "student_groups")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudentGroup {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String groupName;

    private Integer year;
    
    private String course;
    
    private String period;
    
    @Column(length = 1000)
    private String description;
    
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Builder.Default
    private Boolean isActive = true;
}
