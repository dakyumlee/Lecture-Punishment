package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.StudentSubmission;
import com.dungeon.heotaehoon.entity.SubmissionAnswer;
import com.dungeon.heotaehoon.repository.StudentSubmissionRepository;
import com.dungeon.heotaehoon.repository.SubmissionAnswerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/api/grading")
@RequiredArgsConstructor
public class GradingController {

    private final StudentSubmissionRepository submissionRepository;
    private final SubmissionAnswerRepository answerRepository;

    @GetMapping("/submissions")
    public ResponseEntity<List<Map<String, Object>>> getAllSubmissions() {
        log.info("Fetching all submissions");
        
        List<StudentSubmission> submissions = submissionRepository.findAll();
        
        List<Map<String, Object>> result = submissions.stream()
            .map(submission -> {
                Map<String, Object> data = new HashMap<>();
                data.put("id", submission.getId());
                data.put("studentName", submission.getStudent().getDisplayName());
                data.put("studentId", submission.getStudent().getId());
                data.put("worksheetTitle", submission.getWorksheet().getTitle());
                data.put("worksheetId", submission.getWorksheet().getId());
                data.put("score", submission.getScore());
                data.put("correctCount", submission.getCorrectCount());
                data.put("totalQuestions", submission.getTotalQuestions());
                data.put("submittedAt", submission.getSubmittedAt());
                
                int percentage = submission.getTotalQuestions() > 0 
                    ? (submission.getCorrectCount() * 100 / submission.getTotalQuestions()) 
                    : 0;
                data.put("percentage", percentage);
                
                return data;
            })
            .sorted((a, b) -> ((Date) b.get("submittedAt")).compareTo((Date) a.get("submittedAt")))
            .collect(Collectors.toList());
        
        return ResponseEntity.ok(result);
    }

    @GetMapping("/submissions/{submissionId}")
    public ResponseEntity<Map<String, Object>> getSubmissionDetail(@PathVariable String submissionId) {
        log.info("Fetching submission detail: {}", submissionId);
        
        StudentSubmission submission = submissionRepository.findById(submissionId)
                .orElseThrow(() -> new RuntimeException("제출을 찾을 수 없습니다"));
        
        List<SubmissionAnswer> answers = answerRepository.findBySubmission(submission);
        
        Map<String, Object> result = new HashMap<>();
        result.put("id", submission.getId());
        result.put("studentName", submission.getStudent().getDisplayName());
        result.put("worksheetTitle", submission.getWorksheet().getTitle());
        result.put("score", submission.getScore());
        result.put("correctCount", submission.getCorrectCount());
        result.put("totalQuestions", submission.getTotalQuestions());
        result.put("submittedAt", submission.getSubmittedAt());
        result.put("answers", answers.stream().map(answer -> {
            Map<String, Object> answerData = new HashMap<>();
            answerData.put("id", answer.getId());
            answerData.put("questionText", answer.getQuestion().getQuestionText());
            answerData.put("studentAnswer", answer.getStudentAnswer());
            answerData.put("correctAnswer", answer.getQuestion().getCorrectAnswer());
            answerData.put("isCorrect", answer.getIsCorrect());
            answerData.put("score", answer.getScore());
            return answerData;
        }).collect(Collectors.toList()));
        
        return ResponseEntity.ok(result);
    }

    @PostMapping("/answers/{answerId}/grade")
    public ResponseEntity<Map<String, Object>> gradeAnswer(
            @PathVariable String answerId,
            @RequestBody Map<String, Object> request) {
        
        Boolean isCorrect = (Boolean) request.get("isCorrect");
        Integer score = (Integer) request.get("score");
        
        log.info("Grading answer {}: isCorrect={}, score={}", answerId, isCorrect, score);
        
        SubmissionAnswer answer = answerRepository.findById(answerId)
                .orElseThrow(() -> new RuntimeException("답안을 찾을 수 없습니다"));
        
        answer.setIsCorrect(isCorrect);
        answer.setScore(score);
        answerRepository.save(answer);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("answerId", answerId);
        result.put("isCorrect", isCorrect);
        result.put("score", score);
        
        return ResponseEntity.ok(result);
    }
}
