package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.service.QuizService;
import com.dungeon.heotaehoon.service.AIService;
import com.dungeon.heotaehoon.service.InstructorService;
import com.dungeon.heotaehoon.service.StudentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/quiz")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class QuizController {

    private final QuizService quizService;
    private final AIService aiService;
    private final InstructorService instructorService;
    private final StudentService studentService;

    @PostMapping("/result")
    public ResponseEntity<Map<String, Object>> submitQuizResult(@RequestBody Map<String, Object> request) {
        try {
            String studentId = (String) request.get("studentId");
            Integer correctCount = (Integer) request.get("correctCount");
            Integer totalQuestions = (Integer) request.get("totalQuestions");
            String subject = (String) request.getOrDefault("subject", "일반");
            
            if (correctCount == null || totalQuestions == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "correctCount와 totalQuestions는 필수입니다"));
            }
            
            double scorePercent = (double) correctCount / totalQuestions * 100;
            
            String comment = generateComment(scorePercent, subject, correctCount, totalQuestions);
            Map<String, Integer> rewards = calculateRewards(scorePercent);
            
            if (studentId != null) {
                try {
                    studentService.addExp(studentId, rewards.get("exp"));
                    studentService.addPoints(studentId, rewards.get("points"));
                } catch (Exception e) {
                    log.error("학생 보상 지급 실패: {}", e.getMessage());
                }
            }
            
            try {
                int instructorExp = (int) (scorePercent >= 80 ? 10 : scorePercent >= 60 ? 5 : 2);
                instructorService.addInstructorExp("default-instructor", instructorExp);
            } catch (Exception e) {
                log.error("강사 EXP 추가 실패: {}", e.getMessage());
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("comment", comment);
            response.put("rewards", rewards);
            response.put("scorePercent", scorePercent);
            response.put("correctCount", correctCount);
            response.put("totalQuestions", totalQuestions);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("퀴즈 결과 제출 실패", e);
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }
    
    private String generateComment(double scorePercent, String subject, int correct, int total) {
        String prompt = String.format(
            "학생이 %s 시험에서 %d문제 중 %d문제를 맞춰서 %.1f%%의 점수를 받았습니다. " +
            "허태훈 강사의 캐릭터(엄격하지만 학생을 생각하는 교육자)로 30자 이내의 짧고 강렬한 한마디를 해주세요. " +
            "이모티콘 없이 순수 텍스트만, 반말로 작성해주세요.",
            subject, total, correct, scorePercent
        );
        
        try {
            return aiService.generateText(prompt);
        } catch (Exception e) {
            log.error("AI 코멘트 생성 실패, 기본 코멘트 사용", e);
            return getDefaultComment(scorePercent);
        }
    }
    
    private String getDefaultComment(double scorePercent) {
        if (scorePercent == 100) {
            return "완벽하다! 이게 바로 프로지!";
        } else if (scorePercent >= 90) {
            return "잘했어. 이 정도면 인정한다.";
        } else if (scorePercent >= 80) {
            return "괜찮은데? 계속 유지해봐.";
        } else if (scorePercent >= 70) {
            return "그냥저냥이네. 더 노력해.";
        } else if (scorePercent >= 60) {
            return "이 정도로 만족하냐?";
        } else if (scorePercent >= 50) {
            return "반타작이면 부끄러운 줄 알아야지.";
        } else if (scorePercent >= 40) {
            return "너 진짜... 복습 10번 해.";
        } else if (scorePercent >= 30) {
            return "이건 공부를 안 한 거지?";
        } else {
            return "너 나가. 당장 복습부터 하고 와.";
        }
    }
    
    private Map<String, Integer> calculateRewards(double scorePercent) {
        Map<String, Integer> rewards = new HashMap<>();
        
        if (scorePercent == 100) {
            rewards.put("exp", 50);
            rewards.put("points", 500);
        } else if (scorePercent >= 90) {
            rewards.put("exp", 40);
            rewards.put("points", 400);
        } else if (scorePercent >= 80) {
            rewards.put("exp", 30);
            rewards.put("points", 300);
        } else if (scorePercent >= 70) {
            rewards.put("exp", 25);
            rewards.put("points", 250);
        } else if (scorePercent >= 60) {
            rewards.put("exp", 20);
            rewards.put("points", 200);
        } else if (scorePercent >= 50) {
            rewards.put("exp", 15);
            rewards.put("points", 150);
        } else if (scorePercent >= 40) {
            rewards.put("exp", 10);
            rewards.put("points", 100);
        } else {
            rewards.put("exp", 5);
            rewards.put("points", 50);
        }
        
        return rewards;
    }
}
