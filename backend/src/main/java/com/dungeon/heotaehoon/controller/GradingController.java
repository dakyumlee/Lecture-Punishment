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

    @GetMapping("/submission/{submissionId}")
    public ResponseEntity<?> getSubmissionForGrading(@PathVariable Long submissionId) {
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

    @PostMapping("/manual/{answerId}")
    public ResponseEntity<?> manualGrade(
            @PathVariable Long answerId,
            @RequestBody Map<String, Object> gradeData) {
        try {
            SubmissionAnswer answer = answerRepository.findById(answerId)
                    .orElseThrow(() -> new RuntimeException("답안을 찾을 수 없습니다"));

            Boolean isCorrect = (Boolean) gradeData.get("isCorrect");
            Integer score = (Integer) gradeData.get("score");
            String feedback = (String) gradeData.get("feedback");

            answer.setIsCorrect(isCorrect);
            answer.setScore(score);
            answer.setFeedback(feedback);
            answer.setGradedManually(true);

            answerRepository.save(answer);

            updateSubmissionScore(answer.getSubmission().getId());

            return ResponseEntity.ok(answer);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/ai/{answerId}")
    public ResponseEntity<?> aiGrade(@PathVariable Long answerId) {
        try {
            SubmissionAnswer answer = answerRepository.findById(answerId)
                    .orElseThrow(() -> new RuntimeException("답안을 찾을 수 없습니다"));

            WorksheetQuestion question = answer.getQuestion();
            String studentAnswer = answer.getStudentAnswer();

            Map<String, Object> evaluation = aiEvaluationService.evaluateAnswer(
                    question.getQuestionText(),
                    question.getCorrectAnswer(),
                    studentAnswer
            );

            answer.setIsCorrect((Boolean) evaluation.get("isCorrect"));
            answer.setScore((Integer) evaluation.get("score"));
            answer.setFeedback((String) evaluation.get("feedback"));
            answer.setGradedManually(false);

            answerRepository.save(answer);

            updateSubmissionScore(answer.getSubmission().getId());

            return ResponseEntity.ok(answer);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/batch/{submissionId}")
    public ResponseEntity<?> batchGrade(@PathVariable Long submissionId) {
        try {
            StudentSubmission submission = submissionRepository.findById(submissionId)
                    .orElseThrow(() -> new RuntimeException("제출을 찾을 수 없습니다"));

            List<SubmissionAnswer> answers = answerRepository.findBySubmission_Id(submissionId);

            for (SubmissionAnswer answer : answers) {
                if (!answer.getGradedManually()) {
                    WorksheetQuestion question = answer.getQuestion();
                    Map<String, Object> evaluation = aiEvaluationService.evaluateAnswer(
                            question.getQuestionText(),
                            question.getCorrectAnswer(),
                            answer.getStudentAnswer()
                    );

                    answer.setIsCorrect((Boolean) evaluation.get("isCorrect"));
                    answer.setScore((Integer) evaluation.get("score"));
                    answer.setFeedback((String) evaluation.get("feedback"));
                }
            }

            answerRepository.saveAll(answers);
            updateSubmissionScore(submissionId);

            return ResponseEntity.ok(Map.of("message", "일괄 채점 완료"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    private void updateSubmissionScore(Long submissionId) {
        List<SubmissionAnswer> answers = answerRepository.findBySubmission_Id(submissionId);
        int totalScore = answers.stream()
                .mapToInt(a -> a.getScore() != null ? a.getScore() : 0)
                .sum();

        StudentSubmission submission = submissionRepository.findById(submissionId)
                .orElseThrow(() -> new RuntimeException("제출을 찾을 수 없습니다"));
        submission.setTotalScore(totalScore);
        submissionRepository.save(submission);
    }
}
