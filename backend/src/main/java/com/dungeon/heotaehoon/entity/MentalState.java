package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "mental_states")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MentalState {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id")
    private Student student;
    
    @Column(nullable = false)
    private Integer mentalGauge;
    
    @Column(nullable = false)
    private Integer consecutiveWrongs;
    
    @Column(nullable = false)
    private Integer consecutiveCorrects;
    
    private String currentMood;
    
    private Boolean isInCrisis;
    
    private LocalDateTime lastBreakerTime;
    
    private Integer totalBreakdowns;
    
    private Integer totalRecoveries;
    
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(nullable = false)
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (mentalGauge == null) mentalGauge = 100;
        if (consecutiveWrongs == null) consecutiveWrongs = 0;
        if (consecutiveCorrects == null) consecutiveCorrects = 0;
        if (isInCrisis == null) isInCrisis = false;
        if (totalBreakdowns == null) totalBreakdowns = 0;
        if (totalRecoveries == null) totalRecoveries = 0;
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
