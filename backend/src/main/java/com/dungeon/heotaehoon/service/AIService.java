package com.dungeon.heotaehoon.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@Service
@RequiredArgsConstructor
public class AIService {

    @Value("${openai.api.key}")
    private String apiKey;

    @Value("${openai.model}")
    private String model;

    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public String generateQuiz(String lessonTitle, String lessonSubject, int difficulty) {
        return generateQuiz(lessonTitle, lessonSubject, difficulty, null, null);
    }

    public String generateQuiz(String lessonTitle, String lessonSubject, int difficulty, 
                            String previousQuestion, String previousAnswer) {
        String contextPrompt = "";
        
        if (previousQuestion != null && previousAnswer != null) {
            contextPrompt = String.format("""
                
                **이전 문제 정보** (이걸 기반으로 연관된 다음 문제를 만들어라):
                - 이전 질문: "%s"
                - 이전 정답: "%s"
                
                **연속 문제 규칙**:
                1. 이전 문제와 자연스럽게 연결되는 주제
                2. 난이도를 점진적으로 높여라
                3. 이전 문제에서 다룬 개념을 더 깊이 파고들어라
                4. 실제 응용이나 심화 개념으로 확장해라
                
                예시 흐름:
                "배열이란?" → "배열의 시간복잡도" → "ArrayList vs Array" → "실무 사용 사례"
                """, previousQuestion, previousAnswer);
        }

        String prompt = String.format("""
            너는 "%s" 과목을 가르치는 엄격한 강사다.
            오늘 수업 주제: "%s"
            %s
            
            **중요**: 반드시 오늘 수업 주제("%s")와 직접적으로 관련된 문제만 출제해라.
            난이도: %d/5
            
            다음 형식의 JSON으로 문제를 출제해라:
            {
              "question": "문제 내용 (오늘 수업 주제와 직접 관련)",
              "optionA": "선택지 A",
              "optionB": "선택지 B", 
              "optionC": "선택지 C",
              "optionD": "선택지 D",
              "correctAnswer": "A/B/C/D 중 하나",
              "explanation": "정답 설명"
            }
            
            **절대 규칙**:
            1. 문제는 반드시 "%s" 주제에서만 출제
            2. 다른 주제나 언어는 절대 포함 금지
            3. 실용적이고 실무적인 문제
            4. 난이도 %d에 맞게 조정
            5. 코드 예제가 필요하면 명확하게 작성
            
            JSON만 출력하고 다른 텍스트는 출력하지 마라.
            """, lessonTitle, lessonSubject, contextPrompt, lessonSubject, difficulty, lessonSubject, difficulty);

        try {
            String requestBody = objectMapper.writeValueAsString(new OpenAIRequest(
                model,
                new OpenAIRequest.Message[]{
                    new OpenAIRequest.Message("system", "당신은 꼬리물기식 연속 문제를 만드는 교육 전문가입니다. 이전 문제와 자연스럽게 연결되는 심화 문제를 생성합니다."),
                    new OpenAIRequest.Message("user", prompt)
                },
                1500,
                0.8
            ));

            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://api.openai.com/v1/chat/completions"))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + apiKey)
                .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            
            JsonNode rootNode = objectMapper.readTree(response.body());
            String content = rootNode.path("choices").get(0).path("message").path("content").asText();
            
            content = content.trim();
            if (content.startsWith("```json")) {
                content = content.substring(7);
            }
            if (content.startsWith("```")) {
                content = content.substring(3);
            }
            if (content.endsWith("```")) {
                content = content.substring(0, content.length() - 3);
            }
            
            return content.trim();
        } catch (Exception e) {
            throw new RuntimeException("AI 퀴즈 생성 실패: " + e.getMessage());
        }
    }

    public String generateRageMessage(int intensity) {
        String[] rageMessages = {
            "목졸라뿐다",
            "니대가리로 이해가 가긴하겠니",
            "복습을 했으면 이럴 리가 없지 ㅋㅋ",
            "야 그건 기본이잖아",
            "이게 틀려? 진짜?",
            "수업 들었어 안 들었어?",
            "숙제 안 하고 왔지?",
            "아니 이건 초등학생도 푸는데"
        };
        
        if (intensity <= 0 || intensity > rageMessages.length) {
            intensity = (int) (Math.random() * rageMessages.length);
        }
        
        return rageMessages[Math.min(intensity - 1, rageMessages.length - 1)];
    }

    public String generatePraise(int comboCount) {
        if (comboCount >= 5) {
            return "오, 제대로 공부했네? 계속 이렇게 해";
        } else if (comboCount >= 3) {
            return "오, 드디어 정신 차렸네?";
        } else {
            return "이 정도는 해야 기본이지";
        }
    }

    record OpenAIRequest(String model, Message[] messages, int max_tokens, double temperature) {
        record Message(String role, String content) {}
    }

    public String generateText(String prompt) {
        try {
            String requestBody = objectMapper.writeValueAsString(new OpenAIRequest(
                model,
                new OpenAIRequest.Message[]{
                    new OpenAIRequest.Message("system", "당신은 엄격하지만 학생을 생각하는 허태훈 강사입니다."),
                    new OpenAIRequest.Message("user", prompt)
                },
                4000,
                0.9
            ));

            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://api.openai.com/v1/chat/completions"))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + apiKey)
                .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            
            JsonNode rootNode = objectMapper.readTree(response.body());
            String content = rootNode.path("choices").get(0).path("message").path("content").asText();
            
            return content.trim();
        } catch (Exception e) {
            throw new RuntimeException("AI 텍스트 생성 실패: " + e.getMessage());
        }
    }
}
