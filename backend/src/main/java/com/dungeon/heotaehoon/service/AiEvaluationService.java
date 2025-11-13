package com.dungeon.heotaehoon.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AiEvaluationService {

    private final AIService aiService;

    public boolean evaluateAnswer(String question, String correctAnswer, String studentAnswer) {
        if (studentAnswer == null || studentAnswer.trim().isEmpty()) {
            return false;
        }

        String normalizedCorrect = correctAnswer.toLowerCase().trim();
        String normalizedStudent = studentAnswer.toLowerCase().trim();

        if (normalizedCorrect.equals(normalizedStudent)) {
            return true;
        }

        return calculateSimilarity(normalizedCorrect, normalizedStudent) > 0.85;
    }

    private double calculateSimilarity(String s1, String s2) {
        int longer = Math.max(s1.length(), s2.length());
        if (longer == 0) {
            return 1.0;
        }
        return (longer - computeLevenshteinDistance(s1, s2)) / (double) longer;
    }

    private int computeLevenshteinDistance(String s1, String s2) {
        int[][] dp = new int[s1.length() + 1][s2.length() + 1];

        for (int i = 0; i <= s1.length(); i++) {
            dp[i][0] = i;
        }
        for (int j = 0; j <= s2.length(); j++) {
            dp[0][j] = j;
        }

        for (int i = 1; i <= s1.length(); i++) {
            for (int j = 1; j <= s2.length(); j++) {
                int cost = s1.charAt(i - 1) == s2.charAt(j - 1) ? 0 : 1;
                dp[i][j] = Math.min(
                        Math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1),
                        dp[i - 1][j - 1] + cost
                );
            }
        }

        return dp[s1.length()][s2.length()];
    }
}
