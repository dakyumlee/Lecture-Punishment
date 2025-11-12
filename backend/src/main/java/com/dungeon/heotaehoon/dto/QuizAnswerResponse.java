package com.dungeon.heotaehoon.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizAnswerResponse {
    private Boolean isCorrect;
    private String correctAnswer;
    private Integer expGained;
    private Integer studentLevel;
    private Integer studentExp;
    private Boolean levelUp;
    private String rageDialogue;
    private Integer comboCount;
    private Integer bossCurrentHp;
    private Boolean bossDefeated;
    private Integer instructorRageGauge;
    private String instructorEvolutionStage;
}
