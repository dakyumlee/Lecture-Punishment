package com.dungeon.heotaehoon.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.util.Map;
import java.util.HashMap;

@Service
public class AiServiceClient {
    
    @Value("${ai.service.url:http://localhost:5000}")
    private String aiServiceUrl;
    
    private final RestTemplate restTemplate = new RestTemplate();
    
    public String generateRageDialogue(String dialogueType, String studentName, String question, 
                                      String wrongAnswer, String correctAnswer, int combo) {
        try {
            String url = aiServiceUrl + "/api/ai/rage-dialogue";
            
            Map<String, Object> request = new HashMap<>();
            request.put("dialogueType", dialogueType);
            request.put("studentName", studentName);
            request.put("question", question);
            request.put("wrongAnswer", wrongAnswer);
            request.put("correctAnswer", correctAnswer);
            request.put("combo", combo);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);
            
            ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);
            
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                return (String) response.getBody().get("dialogue");
            }
            
            return getFallbackMessage(dialogueType);
            
        } catch (Exception e) {
            System.err.println("AI Service Error: " + e.getMessage());
            return getFallbackMessage(dialogueType);
        }
    }
    
    private String getFallbackMessage(String type) {
        switch (type) {
            case "wrong_answer":
                return "너는 복습을 했니? 했으면 이럴 리가 없지 ㅋㅋ";
            case "correct_answer":
                return "음... 이번엔 운이 좋았네";
            case "mental_break":
                return "아니야, 네가 못한 게 아니라 세상이 널 버린 거야";
            case "combo_3":
                return "오, 이건 좀 하는데?";
            case "combo_broken":
                return "거기까지였구나";
            default:
                return "복습 좀 해라";
        }
    }
}
