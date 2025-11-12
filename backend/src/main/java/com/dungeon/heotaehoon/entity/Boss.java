package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.time.LocalDateTime;

@Entity
@Table(name = "bosses")
public class Boss {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "lesson_id")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Lesson lesson;

    @Column(nullable = false)
    private String name;

    @Column(name = "hp_total")
    private Integer hpTotal;

    @Column(name = "hp_current")
    private Integer hpCurrent;

    @Column(name = "is_defeated")
    private Boolean isDefeated = false;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (isDefeated == null) {
            isDefeated = false;
        }
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Lesson getLesson() {
        return lesson;
    }

    public void setLesson(Lesson lesson) {
        this.lesson = lesson;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getHpTotal() {
        return hpTotal;
    }

    public void setHpTotal(Integer hpTotal) {
        this.hpTotal = hpTotal;
    }

    public Integer getHpCurrent() {
        return hpCurrent;
    }

    public void setHpCurrent(Integer hpCurrent) {
        this.hpCurrent = hpCurrent;
    }

    public Boolean getIsDefeated() {
        return isDefeated;
    }

    public void setIsDefeated(Boolean isDefeated) {
        this.isDefeated = isDefeated;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
