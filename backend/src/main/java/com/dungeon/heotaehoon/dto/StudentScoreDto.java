package com.dungeon.heotaehoon.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudentScoreDto {
    private String studentId;
    private String studentName;
    private String username;
    private Integer level;
    private Integer totalCorrect;
    private Integer totalWrong;
    private Double successRate;
    private Integer totalScore;
    private String groupName;
    private Integer year;
    private String course;
}
