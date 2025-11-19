package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Quiz;
import com.dungeon.heotaehoon.service.QuizService;
import com.dungeon.heotaehoon.service.InstructorService;
import com.dungeon.heotaehoon.service.AiQuizGenerationService;
import com.dungeon.heotaehoon.service.AiServiceClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/quizzes")
@RequiredArgsConstructor
public class QuizController {
    
    private final QuizService quizService;
    private final InstructorService instructorService;
    private final AiQuizGenerationService aiQuizGenerationService;
    private final AiServiceClient aiServiceClient;

    @GetMapping("/boss/{bossId}")
    public ResponseEntity<List<Quiz>> getQuizzesByBoss(@PathVariable String bossId) {
        log.info("Fetching quizzes for boss: {}", bossId);
        List<Quiz> quizzes = quizService.getQuizzesByBoss(bossId);
        return ResponseEntity.ok(quizzes);
    }

    @GetMapping("/lesson/{lessonId}")
    public ResponseEntity<List<Quiz>> getQuizzesByLesson(@PathVariable String lessonId) {
        log.info("Fetching quizzes for lesson: {}", lessonId);
        List<Quiz> quizzes = quizService.getQuizzesByLesson(lessonId);
        return ResponseEntity.ok(quizzes);
    }

    @PostMapping("/{quizId}/submit")
    public ResponseEntity<Map<String, Object>> submitAnswer(
            @PathVariable String quizId,
            @RequestBody Map<String, String> request) {
        
        String studentId = request.get("studentId");
        String selectedAnswer = request.get("selectedAnswer");
        
        log.info("Student {} submitted answer {} for quiz {}", studentId, selectedAnswer, quizId);
        
        Map<String, Object> result = quizService.submitAnswer(quizId, studentId, selectedAnswer);
        return ResponseEntity.ok(result);
    }

    @PostMapping
    public ResponseEntity<Quiz> createQuiz(@RequestBody Map<String, Object> request) {
        String lessonId = (String) request.get("lessonId");
        String bossId = (String) request.get("bossId");
        
        Quiz quiz = quizService.createQuiz(lessonId, bossId, request);
        return ResponseEntity.ok(quiz);
    }

    @PostMapping("/generate-ai")
    public ResponseEntity<List<Quiz>> generateAiQuizzes(@RequestBody Map<String, Object> request) {
        String bossId = (String) request.get("bossId");
        String topic = (String) request.get("topic");
        Integer count = (Integer) request.getOrDefault("count", 5);
        
        log.info("Generating AI quizzes for boss: {}, topic: {}, count: {}", bossId, topic, count);
        
        List<Quiz> quizzes = aiQuizGenerationService.generateQuizzesForBoss(bossId, topic, count);
        return ResponseEntity.ok(quizzes);
    }

    @PostMapping("/rage-dialogue")
    public ResponseEntity<Map<String, String>> getRageDialogue(@RequestBody Map<String, Object> request) {
        String dialogueType = (String) request.get("dialogueType");
        String studentName = (String) request.getOrDefault("studentName", "학생");
        String question = (String) request.getOrDefault("question", "");
        String wrongAnswer = (String) request.getOrDefault("wrongAnswer", "");
        String correctAnswer = (String) request.getOrDefault("correctAnswer", "");
        Integer combo = (Integer) request.getOrDefault("combo", 0);
        
        String dialogue = aiServiceClient.generateRageDialogue(
            dialogueType, studentName, question, wrongAnswer, correctAnswer, combo
        );
        
        Map<String, String> response = new HashMap<>();
        response.put("dialogue", dialogue);
        response.put("dialogueType", dialogueType);
        
        return ResponseEntity.ok(response);
    }
}
