package com.dungeon.heotaehoon.dto;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudentDTO {
    private UUID id;
    private String username;
    private String displayName;
    private Integer level;
    private Integer exp;
    private Integer totalCorrect;
    private Integer totalWrong;
    private Integer mentalGauge;
    private String characterOutfit;
    private String characterExpression;
    private Double accuracyRate;
}
