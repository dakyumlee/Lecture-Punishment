package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Boss;
import com.dungeon.heotaehoon.entity.Quiz;
import com.dungeon.heotaehoon.repository.BossRepository;
import com.dungeon.heotaehoon.repository.QuizRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class AiQuizGenerationService {
    
    private final QuizRepository quizRepository;
    private final BossRepository bossRepository;
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    @Value("${openai.api.key:}")
    private String openaiApiKey;

    public List<Quiz> generateQuizzesForBoss(String bossId, String topic, int count) {
        Boss boss = bossRepository.findById(bossId)
                .orElseThrow(() -> new RuntimeException("Boss not found"));
        
        log.info("Generating {} quizzes for boss: {} on topic: {}", count, boss.getBossName(), topic);
        
        String prompt = String.format(
            "당신은 '%s' 보스입니다. '%s' 주제로 학생들을 테스트할 객관식 문제 %d개를 생성하세요.\n\n" +
            "각 문제는 다음 JSON 형식으로 작성하세요:\n" +
            "{\n" +
            "  \"question\": \"문제 텍스트\",\n" +
            "  \"optionA\": \"보기 1\",\n" +
            "  \"optionB\": \"보기 2\",\n" +
            "  \"optionC\": \"보기 3\",\n" +
            "  \"optionD\": \"보기 4\",\n" +
            "  \"correctAnswer\": \"1\",\n" +
            "  \"explanation\": \"정답 해설\",\n" +
            "  \"difficultyLevel\": 2\n" +
            "}\n\n" +
            "난이도는 1(쉬움)~5(어려움)로 설정하세요.\n" +
            "JSON 배열로 %d개의 문제를 반환하세요.",
            boss.getBossName(), topic, count, count
        );
        
        try {
            String gptResponse = callGPT4(prompt);
            List<Map<String, Object>> quizData = parseGPTResponse(gptResponse);
            
            List<Quiz> quizzes = new ArrayList<>();
            for (Map<String, Object> data : quizData) {
                Quiz quiz = Quiz.builder()
                        .boss(boss)
                        .question((String) data.get("question"))
                        .optionA((String) data.get("optionA"))
                        .optionB((String) data.get("optionB"))
                        .optionC((String) data.get("optionC"))
                        .optionD((String) data.get("optionD"))
                        .correctAnswer((String) data.get("correctAnswer"))
                        .explanation((String) data.get("explanation"))
                        .difficultyLevel(((Number) data.getOrDefault("difficultyLevel", 2)).intValue())
                        .createdAt(LocalDateTime.now())
                        .build();
                
                quizzes.add(quizRepository.save(quiz));
            }
            
            log.info("Successfully generated {} quizzes", quizzes.size());
            return quizzes;
            
        } catch (Exception e) {
            log.error("Failed to generate quizzes", e);
            throw new RuntimeException("AI 퀴즈 생성 실패: " + e.getMessage());
        }
    }

    private String callGPT4(String prompt) throws Exception {
        if (openaiApiKey == null || openaiApiKey.isEmpty()) {
            throw new RuntimeException("OpenAI API 키가 설정되지 않았습니다");
        }
        
        String url = "https://api.openai.com/v1/chat/completions";
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(openaiApiKey);
        
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", "gpt-4");
        requestBody.put("messages", List.of(
                Map.of("role", "system", "content", "당신은 교육 콘텐츠 전문가입니다."),
                Map.of("role", "user", "content", prompt)
        ));
        requestBody.put("temperature", 0.7);
        
        HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);
        
        Map<String, Object> response = restTemplate.postForObject(url, request, Map.class);
        
        List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
        Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
        
        return (String) message.get("content");
    }

    private List<Map<String, Object>> parseGPTResponse(String response) throws Exception {
        String jsonContent = response.trim();
        
        if (jsonContent.startsWith("```json")) {
            jsonContent = jsonContent.substring(7);
        }
        if (jsonContent.startsWith("```")) {
            jsonContent = jsonContent.substring(3);
        }
        if (jsonContent.endsWith("```")) {
            jsonContent = jsonContent.substring(0, jsonContent.length() - 3);
        }
        
        jsonContent = jsonContent.trim();
        
        return objectMapper.readValue(jsonContent, List.class);
    }
}
