package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.SubmissionAnswer;
import com.dungeon.heotaehoon.entity.StudentSubmission;
import com.dungeon.heotaehoon.entity.WorksheetQuestion;
import com.dungeon.heotaehoon.repository.SubmissionAnswerRepository;
import com.dungeon.heotaehoon.repository.StudentSubmissionRepository;
import com.dungeon.heotaehoon.repository.WorksheetQuestionRepository;
import com.dungeon.heotaehoon.service.AiEvaluationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/grading")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class GradingController {

    private final StudentSubmissionRepository submissionRepository;
    private final SubmissionAnswerRepository answerRepository;
    private final WorksheetQuestionRepository questionRepository;
    private final AiEvaluationService aiEvaluationService;

    @GetMapping("/submissions")
    public ResponseEntity<List<StudentSubmission>> getAllSubmissions() {
        return ResponseEntity.ok(submissionRepository.findAll());
    }

    @GetMapping("/submissions/{submissionId}")
    public ResponseEntity<?> getSubmissionDetail(@PathVariable String submissionId) {
        try {
            StudentSubmission submission = submissionRepository.findById(submissionId)
                    .orElseThrow(() -> new RuntimeException("제출을 찾을 수 없습니다"));

            List<SubmissionAnswer> answers = answerRepository.findBySubmission_Id(submissionId);

            Map<String, Object> result = new HashMap<>();
            result.put("submission", submission);
            result.put("answers", answers);

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/submission/{submissionId}")
    public ResponseEntity<?> getSubmissionForGrading(@PathVariable String submissionId) {
        try {
            StudentSubmission submission = submissionRepository.findById(submissionId)
                    .orElseThrow(() -> new RuntimeException("제출을 찾을 수 없습니다"));

            List<SubmissionAnswer> answers = answerRepository.findBySubmission_Id(submissionId);

            Map<String, Object> result = new HashMap<>();
            result.put("submission", submission);
            result.put("answers", answers);

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/answers/{answerId}/grade")
    public ResponseEntity<?> gradeAnswer(
            @PathVariable String answerId,
            @RequestBody Map<String, Object> gradeData) {
        try {
            SubmissionAnswer answer = answerRepository.findById(answerId)
                    .orElseThrow(() -> new RuntimeException("답안을 찾을 수 없습니다"));

            Boolean isCorrect = (Boolean) gradeData.get("isCorrect");
            Integer score = (Integer) gradeData.get("score");

            answer.setIsCorrect(isCorrect);
            answer.setPointsEarned(score);

            answerRepository.save(answer);

            updateSubmissionScore(answer.getSubmission().getId());

            return ResponseEntity.ok(answer);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/manual/{answerId}")
    public ResponseEntity<?> manualGrade(
            @PathVariable String answerId,
            @RequestBody Map<String, Object> gradeData) {
        try {
            SubmissionAnswer answer = answerRepository.findById(answerId)
                    .orElseThrow(() -> new RuntimeException("답안을 찾을 수 없습니다"));

            Boolean isCorrect = (Boolean) gradeData.get("isCorrect");
            Integer points = (Integer) gradeData.get("points");

            answer.setIsCorrect(isCorrect);
            answer.setPointsEarned(points);

            answerRepository.save(answer);

            updateSubmissionScore(answer.getSubmission().getId());

            return ResponseEntity.ok(answer);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/ai/{answerId}")
    public ResponseEntity<?> aiGrade(@PathVariable String answerId) {
        try {
            SubmissionAnswer answer = answerRepository.findById(answerId)
                    .orElseThrow(() -> new RuntimeException("답안을 찾을 수 없습니다"));

            WorksheetQuestion question = answer.getQuestion();
            String studentAnswer = answer.getStudentAnswer();

            boolean isCorrect = aiEvaluationService.evaluateAnswer(
                    question.getQuestionText(),
                    question.getCorrectAnswer(),
                    studentAnswer
            );

            answer.setIsCorrect(isCorrect);
            answer.setPointsEarned(isCorrect ? question.getPoints() : 0);

            answerRepository.save(answer);

            updateSubmissionScore(answer.getSubmission().getId());

            return ResponseEntity.ok(answer);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/batch/{submissionId}")
    public ResponseEntity<?> batchGrade(@PathVariable String submissionId) {
        try {
            StudentSubmission submission = submissionRepository.findById(submissionId)
                    .orElseThrow(() -> new RuntimeException("제출을 찾을 수 없습니다"));

            List<SubmissionAnswer> answers = answerRepository.findBySubmission_Id(submissionId);

            for (SubmissionAnswer answer : answers) {
                WorksheetQuestion question = answer.getQuestion();
                boolean isCorrect = aiEvaluationService.evaluateAnswer(
                        question.getQuestionText(),
                        question.getCorrectAnswer(),
                        answer.getStudentAnswer()
                );

                answer.setIsCorrect(isCorrect);
                answer.setPointsEarned(isCorrect ? question.getPoints() : 0);
            }

            answerRepository.saveAll(answers);
            updateSubmissionScore(submissionId);

            return ResponseEntity.ok(Map.of("message", "일괄 채점 완료"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    private void updateSubmissionScore(String submissionId) {
        List<SubmissionAnswer> answers = answerRepository.findBySubmission_Id(submissionId);
        int totalScore = answers.stream()
                .mapToInt(a -> a.getPointsEarned() != null ? a.getPointsEarned() : 0)
                .sum();

        StudentSubmission submission = submissionRepository.findById(submissionId)
                .orElseThrow(() -> new RuntimeException("제출을 찾을 수 없습니다"));
        submission.setTotalScore(totalScore);
        submissionRepository.save(submission);
    }
}