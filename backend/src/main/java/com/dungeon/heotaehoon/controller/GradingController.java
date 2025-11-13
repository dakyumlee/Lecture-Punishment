package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.StudentSubmission;
import com.dungeon.heotaehoon.entity.SubmissionAnswer;
import com.dungeon.heotaehoon.repository.StudentSubmissionRepository;
import com.dungeon.heotaehoon.repository.SubmissionAnswerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/grading")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class GradingController {

    private final StudentSubmissionRepository submissionRepository;
    private final SubmissionAnswerRepository answerRepository;

    @GetMapping("/submissions")
    public ResponseEntity<List<Map<String, Object>>> getAllSubmissions() {
        List<StudentSubmission> submissions = submissionRepository.findAll();
        
        List<Map<String, Object>> result = submissions.stream().map(sub -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", sub.getId());
            map.put("studentName", sub.getStudent().getDisplayName());
            map.put("studentId", sub.getStudent().getId());
            map.put("worksheetTitle", sub.getWorksheet().getTitle());
            map.put("worksheetId", sub.getWorksheet().getId());
            map.put("totalScore", sub.getTotalScore());
            map.put("maxScore", sub.getMaxScore());
            map.put("submittedAt", sub.getSubmittedAt().toString());
            return map;
        }).collect(Collectors.toList());
        
        return ResponseEntity.ok(result);
    }

    @GetMapping("/submissions/{submissionId}")
    public ResponseEntity<Map<String, Object>> getSubmissionDetail(@PathVariable String submissionId) {
        StudentSubmission submission = submissionRepository.findById(submissionId)
            .orElseThrow(() -> new RuntimeException("Submission not found"));
        
        List<SubmissionAnswer> answers = answerRepository.findBySubmissionId(submissionId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("id", submission.getId());
        result.put("studentName", submission.getStudent().getDisplayName());
        result.put("studentId", submission.getStudent().getId());
        result.put("worksheetTitle", submission.getWorksheet().getTitle());
        result.put("totalScore", submission.getTotalScore());
        result.put("maxScore", submission.getMaxScore());
        result.put("submittedAt", submission.getSubmittedAt().toString());
        
        List<Map<String, Object>> answerList = answers.stream().map(ans -> {
            Map<String, Object> ansMap = new HashMap<>();
            ansMap.put("id", ans.getId());
            ansMap.put("questionNumber", ans.getQuestion().getQuestionNumber());
            ansMap.put("questionText", ans.getQuestion().getQuestionText());
            ansMap.put("correctAnswer", ans.getQuestion().getCorrectAnswer());
            ansMap.put("studentAnswer", ans.getStudentAnswer());
            ansMap.put("isCorrect", ans.getIsCorrect());
            ansMap.put("pointsEarned", ans.getPointsEarned());
            ansMap.put("maxPoints", ans.getQuestion().getPoints());
            ansMap.put("questionType", ans.getQuestion().getQuestionType());
            return ansMap;
        }).collect(Collectors.toList());
        
        result.put("answers", answerList);
        
        return ResponseEntity.ok(result);
    }

    @PutMapping("/answers/{answerId}/grade")
    public ResponseEntity<Map<String, Object>> gradeAnswer(
            @PathVariable String answerId,
            @RequestBody Map<String, Object> request) {
        
        SubmissionAnswer answer = answerRepository.findById(answerId)
            .orElseThrow(() -> new RuntimeException("Answer not found"));
        
        Integer pointsEarned = (Integer) request.get("pointsEarned");
        Boolean isCorrect = (Boolean) request.get("isCorrect");
        
        answer.setPointsEarned(pointsEarned);
        answer.setIsCorrect(isCorrect);
        answerRepository.save(answer);
        
        recalculateSubmissionScore(answer.getSubmission().getId());
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("answerId", answerId);
        result.put("pointsEarned", pointsEarned);
        
        return ResponseEntity.ok(result);
    }

    @GetMapping("/worksheet/{worksheetId}/submissions")
    public ResponseEntity<List<Map<String, Object>>> getWorksheetSubmissions(@PathVariable String worksheetId) {
        List<StudentSubmission> submissions = submissionRepository.findByWorksheetId(worksheetId);
        
        List<Map<String, Object>> result = submissions.stream().map(sub -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", sub.getId());
            map.put("studentName", sub.getStudent().getDisplayName());
            map.put("studentId", sub.getStudent().getId());
            map.put("totalScore", sub.getTotalScore());
            map.put("maxScore", sub.getMaxScore());
            map.put("submittedAt", sub.getSubmittedAt().toString());
            return map;
        }).collect(Collectors.toList());
        
        return ResponseEntity.ok(result);
    }

    private void recalculateSubmissionScore(String submissionId) {
        StudentSubmission submission = submissionRepository.findById(submissionId)
            .orElseThrow(() -> new RuntimeException("Submission not found"));
        
        List<SubmissionAnswer> answers = answerRepository.findBySubmissionId(submissionId);
        
        int totalScore = answers.stream()
            .mapToInt(ans -> ans.getPointsEarned() != null ? ans.getPointsEarned() : 0)
            .sum();
        
        submission.setTotalScore(totalScore);
        submissionRepository.save(submission);
    }
}
