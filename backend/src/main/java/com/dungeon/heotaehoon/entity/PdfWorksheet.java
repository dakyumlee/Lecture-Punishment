package com.dungeon.heotaehoon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "pdf_worksheets")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PdfWorksheet {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String title;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    private String category;

    @Lob
    @Column(name = "pdf_content", columnDefinition = "BYTEA")
    private byte[] pdfContent;

    private String fileName;

    @Builder.Default
    private Integer totalQuestions = 0;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Builder.Default
    private Boolean isActive = true;
}
