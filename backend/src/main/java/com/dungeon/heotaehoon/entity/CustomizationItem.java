package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "customization_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomizationItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "item_type", nullable = false, length = 20)
    private String itemType;

    @Column(name = "item_value", nullable = false, length = 100)
    private String itemValue;

    @Column(name = "item_name", nullable = false, length = 100)
    private String itemName;

    @Column(nullable = false)
    private Integer price;

    @Column(name = "is_default")
    private Boolean isDefault = false;
}
