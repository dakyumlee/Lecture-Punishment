package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.SubmissionAnswer;
import com.dungeon.heotaehoon.entity.StudentSubmission;
import com.dungeon.heotaehoon.service.WorksheetService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/grading")
@RequiredArgsConstructor
public class GradingController {

    private final WorksheetService worksheetService;

    @GetMapping("/submissions")
    public ResponseEntity<List<Map<String, Object>>> getAllSubmissions() {
        try {
            List<Map<String, Object>> submissions = new ArrayList<>();
            return ResponseEntity.ok(submissions);
        } catch (Exception e) {
            return ResponseEntity.ok(new ArrayList<>());
        }
    }

    @GetMapping("/submissions/{submissionId}")
    public ResponseEntity<Map<String, Object>> getSubmissionDetail(@PathVariable String submissionId) {
        try {
            StudentSubmission submission = worksheetService.getSubmissionById(submissionId);
            List<SubmissionAnswer> answers = worksheetService.getSubmissionAnswers(submissionId);
            
            Map<String, Object> result = new HashMap<>();
            result.put("submission", submission);
            result.put("answers", answers);
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/answers/{answerId}/grade")
    public ResponseEntity<Map<String, Object>> gradeAnswer(
            @PathVariable String answerId,
            @RequestBody Map<String, Object> gradeData) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        return ResponseEntity.ok(result);
    }
}
