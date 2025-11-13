package com.dungeon.heotaehoon.service;

import com.theokanning.openai.completion.chat.ChatCompletionRequest;
import com.theokanning.openai.completion.chat.ChatMessage;
import com.theokanning.openai.service.OpenAiService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class AiEvaluationService {

    @Value("${openai.api.key:}")
    private String apiKey;

    public String generateEvaluation(
        String studentName,
        int totalScore,
        int maxScore,
        List<Map<String, Object>> wrongQuestions
    ) {
        if (apiKey == null || apiKey.isEmpty()) {
            return generateFallbackEvaluation(totalScore, maxScore, wrongQuestions);
        }

        try {
            OpenAiService service = new OpenAiService(apiKey);
            
            double percentage = (double) totalScore / maxScore * 100;
            
            StringBuilder prompt = new StringBuilder();
            prompt.append("학생 이름: ").append(studentName).append("\n");
            prompt.append("점수: ").append(totalScore).append("/").append(maxScore);
            prompt.append(" (").append(String.format("%.1f", percentage)).append("%)\n");
            prompt.append("틀린 문제:\n");
            
            for (Map<String, Object> q : wrongQuestions) {
                prompt.append("- 문제 ").append(q.get("questionNumber")).append(": ");
                prompt.append(q.get("questionText")).append("\n");
            }
            
            prompt.append("\n위 정보를 바탕으로 2-3문장으로 평가의견을 작성해주세요. ");
            prompt.append("존댓말을 사용하고, 구체적인 보완점과 격려를 포함하세요.");

            ChatCompletionRequest request = ChatCompletionRequest.builder()
                .model("gpt-4o-mini")
                .messages(List.of(
                    new ChatMessage("system", "당신은 친절하고 전문적인 교육 평가자입니다."),
                    new ChatMessage("user", prompt.toString())
                ))
                .maxTokens(200)
                .temperature(0.7)
                .build();

            String evaluation = service.createChatCompletion(request)
                .getChoices().get(0).getMessage().getContent();
            
            service.shutdownExecutor();
            return evaluation;
            
        } catch (Exception e) {
            log.error("AI evaluation failed", e);
            return generateFallbackEvaluation(totalScore, maxScore, wrongQuestions);
        }
    }

    private String generateFallbackEvaluation(
        int totalScore,
        int maxScore,
        List<Map<String, Object>> wrongQuestions
    ) {
        double percentage = (double) totalScore / maxScore * 100;
        
        StringBuilder evaluation = new StringBuilder();
        
        if (percentage >= 90) {
            evaluation.append("우수한 이해도를 보였습니다. ");
        } else if (percentage >= 70) {
            evaluation.append("양호한 수준입니다. ");
        } else if (percentage >= 50) {
            evaluation.append("기본 개념은 이해하고 있으나 보충이 필요합니다. ");
        } else {
            evaluation.append("기본 개념 학습이 시급합니다. ");
        }
        
        if (!wrongQuestions.isEmpty()) {
            evaluation.append("특히 ");
            if (wrongQuestions.size() <= 3) {
                for (int i = 0; i < wrongQuestions.size(); i++) {
                    evaluation.append(wrongQuestions.get(i).get("questionNumber")).append("번");
                    if (i < wrongQuestions.size() - 1) evaluation.append(", ");
                }
            } else {
                evaluation.append(wrongQuestions.get(0).get("questionNumber"))
                    .append("번, ")
                    .append(wrongQuestions.get(1).get("questionNumber"))
                    .append("번 등 ")
                    .append(wrongQuestions.size())
                    .append("개");
            }
            evaluation.append(" 문제에 대한 복습이 필요합니다.");
        }
        
        return evaluation.toString();
    }
}
