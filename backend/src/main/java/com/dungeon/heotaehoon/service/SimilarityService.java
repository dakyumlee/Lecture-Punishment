package com.dungeon.heotaehoon.service;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Service
public class SimilarityService {

    public BigDecimal calculateLevenshteinSimilarity(String s1, String s2) {
        if (s1 == null || s2 == null) {
            return BigDecimal.ZERO;
        }
        
        String str1 = normalizeString(s1);
        String str2 = normalizeString(s2);
        
        if (str1.equals(str2)) {
            return BigDecimal.ONE;
        }
        
        int distance = levenshteinDistance(str1, str2);
        int maxLength = Math.max(str1.length(), str2.length());
        
        if (maxLength == 0) {
            return BigDecimal.ONE;
        }
        
        double similarity = 1.0 - ((double) distance / maxLength);
        return BigDecimal.valueOf(similarity).setScale(2, RoundingMode.HALF_UP);
    }

    private String normalizeString(String str) {
        return str.toLowerCase()
                  .replaceAll("\\s+", "")
                  .replaceAll("[^a-z0-9가-힣]", "")
                  .trim();
    }

    private int levenshteinDistance(String s1, String s2) {
        int len1 = s1.length();
        int len2 = s2.length();
        
        int[][] dp = new int[len1 + 1][len2 + 1];
        
        for (int i = 0; i <= len1; i++) {
            dp[i][0] = i;
        }
        
        for (int j = 0; j <= len2; j++) {
            dp[0][j] = j;
        }
        
        for (int i = 1; i <= len1; i++) {
            for (int j = 1; j <= len2; j++) {
                int cost = (s1.charAt(i - 1) == s2.charAt(j - 1)) ? 0 : 1;
                
                dp[i][j] = Math.min(
                    Math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1),
                    dp[i - 1][j - 1] + cost
                );
            }
        }
        
        return dp[len1][len2];
    }

    public boolean isAnswerCorrect(String studentAnswer, String correctAnswer, BigDecimal threshold) {
        if (correctAnswer.equalsIgnoreCase(studentAnswer.trim())) {
            return true;
        }
        
        BigDecimal similarity = calculateLevenshteinSimilarity(studentAnswer, correctAnswer);
        return similarity.compareTo(threshold) >= 0;
    }
}
