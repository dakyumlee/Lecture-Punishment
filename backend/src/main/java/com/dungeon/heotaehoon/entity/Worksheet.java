package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "worksheets")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Worksheet {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String title;

    @Column(length = 1000)
    private String description;

    @ManyToOne
    @JoinColumn(name = "category_id")
    private WorksheetCategory category;

    @Column(name = "group_name")
    private String groupName;

    @OneToMany(mappedBy = "worksheet", cascade = CascadeType.ALL)
    @Builder.Default
    private List<WorksheetQuestion> questions = new ArrayList<>();

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;

    @Builder.Default
    private Boolean isActive = true;

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
    public String getGroup() {
        return this.groupName;
    }
}
