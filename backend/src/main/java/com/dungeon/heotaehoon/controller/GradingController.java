package com.dungeon.heotaehoon.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@Slf4j
@RestController
@RequestMapping("/api/grading")
@RequiredArgsConstructor
public class GradingController {

    @GetMapping("/submissions")
    public ResponseEntity<List<Map<String, Object>>> getAllSubmissions() {
        log.info("Fetching all submissions");
        return ResponseEntity.ok(new ArrayList<>());
    }

    @GetMapping("/submissions/{submissionId}")
    public ResponseEntity<Map<String, Object>> getSubmissionDetail(@PathVariable String submissionId) {
        log.info("Fetching submission detail: {}", submissionId);
        Map<String, Object> result = new HashMap<>();
        result.put("submissionId", submissionId);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/answers/{answerId}/grade")
    public ResponseEntity<Map<String, Object>> gradeAnswer(
            @PathVariable String answerId,
            @RequestBody Map<String, Object> request) {
        
        Boolean isCorrect = (Boolean) request.get("isCorrect");
        Integer score = (Integer) request.get("score");
        
        log.info("Grading answer {}: isCorrect={}, score={}", answerId, isCorrect, score);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("answerId", answerId);
        result.put("isCorrect", isCorrect);
        result.put("score", score);
        
        return ResponseEntity.ok(result);
    }
}
