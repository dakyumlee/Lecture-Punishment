package com.dungeon.heotaehoon.entity;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "shop_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShopItem {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(name = "item_type", nullable = false, length = 50)
    private String itemType;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private Integer price;

    @Column(length = 20)
    private String rarity = "common";

    @Column(name = "image_url", length = 255)
    private String imageUrl;

    @Column(name = "is_available")
    private Boolean isAvailable = true;

    @Column(columnDefinition = "jsonb")
    private String metadata;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }

    @Transient
    public JsonNode getMetadataJson() {
        if (metadata == null) {
            return null;
        }
        try {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readTree(metadata);
        } catch (Exception e) {
            return null;
        }
    }
}
