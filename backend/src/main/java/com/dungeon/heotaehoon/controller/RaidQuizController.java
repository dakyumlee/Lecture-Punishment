package com.dungeon.heotaehoon.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.dungeon.heotaehoon.service.AIService;

import java.util.*;
import java.util.regex.*;

@RestController
@RequestMapping("/quiz")
public class RaidQuizController {

    @Autowired
    private AIService aiService;

    @PostMapping("/generate-raid")
    public ResponseEntity<Map<String, Object>> generateRaidQuiz(@RequestBody Map<String, Object> request) {
        try {
            String topic = (String) request.get("topic");
            Integer difficulty = (Integer) request.get("difficulty");

            if (topic == null || difficulty == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "topic과 difficulty가 필요합니다"));
            }

            String quizJson = aiService.generateQuiz(topic, topic, difficulty);
            
            Map<String, Object> quiz = parseQuizJson(quizJson);
            quiz.put("damage", 500);
            
            return ResponseEntity.ok(quiz);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "문제 생성 실패: " + e.getMessage());
            return ResponseEntity.internalServerError().body(error);
        }
    }

    @PostMapping("/check-raid-answer")
    public ResponseEntity<Map<String, Object>> checkRaidAnswer(@RequestBody Map<String, Object> request) {
        try {
            String answer = (String) request.get("answer");
            String correctAnswer = (String) request.get("correctAnswer");

            Map<String, Object> result = new HashMap<>();
            
            boolean isCorrect = answer != null && 
                              correctAnswer != null && 
                              answer.trim().equalsIgnoreCase(correctAnswer.trim());
            
            result.put("isCorrect", isCorrect);
            result.put("damage", isCorrect ? 500 : 0);
            result.put("message", isCorrect ? "정답입니다!" : "오답입니다!");
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "답안 체크 실패: " + e.getMessage());
            error.put("isCorrect", false);
            error.put("damage", 0);
            return ResponseEntity.ok(error);
        }
    }

    private Map<String, Object> parseQuizJson(String json) {
        Map<String, Object> result = new HashMap<>();
        try {
            json = json.replace("```json", "").replace("```", "").trim();
            
            Pattern questionPattern = Pattern.compile("\"question\"\\s*:\\s*\"([^\"]+)\"");
            Pattern correctPattern = Pattern.compile("\"correct_answer\"\\s*:\\s*\"([^\"]+)\"");
            Pattern optionsPattern = Pattern.compile("\"options\"\\s*:\\s*\\[([^\\]]+)\\]");
            
            Matcher questionMatcher = questionPattern.matcher(json);
            Matcher correctMatcher = correctPattern.matcher(json);
            Matcher optionsMatcher = optionsPattern.matcher(json);
            
            if (questionMatcher.find()) {
                result.put("question", questionMatcher.group(1));
            }
            
            if (correctMatcher.find()) {
                result.put("correctAnswer", correctMatcher.group(1));
            }
            
            if (optionsMatcher.find()) {
                String optionsStr = optionsMatcher.group(1);
                List<String> options = new ArrayList<>();
                Pattern optionPattern = Pattern.compile("\"([^\"]+)\"");
                Matcher optionMatcher = optionPattern.matcher(optionsStr);
                while (optionMatcher.find()) {
                    options.add(optionMatcher.group(1));
                }
                result.put("options", options);
            }
            
            if (!result.containsKey("question")) {
                result.put("question", "레이드 문제를 불러올 수 없습니다");
            }
            if (!result.containsKey("options")) {
                result.put("options", Arrays.asList("A", "B", "C", "D"));
            }
            if (!result.containsKey("correctAnswer")) {
                result.put("correctAnswer", "A");
            }
            
        } catch (Exception e) {
            result.put("question", "파싱 오류: " + e.getMessage());
            result.put("options", Arrays.asList("A", "B", "C", "D"));
            result.put("correctAnswer", "A");
        }
        return result;
    }
}
