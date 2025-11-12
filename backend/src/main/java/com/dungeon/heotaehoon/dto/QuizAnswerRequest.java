package com.dungeon.heotaehoon.dto;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizAnswerRequest {
    private UUID studentId;
    private UUID quizId;
    private String selectedAnswer;
}
