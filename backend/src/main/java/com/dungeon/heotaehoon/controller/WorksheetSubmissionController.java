package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@RestController
@RequestMapping("/api/worksheet-submissions")
@RequiredArgsConstructor
public class WorksheetSubmissionController {

    private final WorksheetRepository worksheetRepository;
    private final WorksheetQuestionRepository questionRepository;
    private final StudentRepository studentRepository;
    private final StudentSubmissionRepository submissionRepository;
    private final SubmissionAnswerRepository answerRepository;

    @PostMapping
    @Transactional
    public ResponseEntity<Map<String, Object>> submitWorksheet(@RequestBody Map<String, Object> request) {
        try {
            String worksheetId = (String) request.get("worksheetId");
            String studentId = (String) request.get("studentId");
            
            @SuppressWarnings("unchecked")
            List<Map<String, String>> answers = (List<Map<String, String>>) request.get("answers");
            
            log.info("Worksheet submission - WorksheetId: {}, StudentId: {}, Answers: {}", 
                worksheetId, studentId, answers.size());
            
            Worksheet worksheet = worksheetRepository.findById(worksheetId)
                    .orElseThrow(() -> new RuntimeException("문제지를 찾을 수 없습니다"));
            
            Student student = studentRepository.findById(studentId)
                    .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
            
            StudentSubmission submission = StudentSubmission.builder()
                    .worksheet(worksheet)
                    .student(student)
                    .submittedAt(LocalDateTime.now())
                    .build();
            
            submission = submissionRepository.save(submission);
            
            int correctCount = 0;
            int totalPoints = 0;
            List<Map<String, Object>> results = new ArrayList<>();
            
            for (Map<String, String> answer : answers) {
                String questionId = answer.get("questionId");
                String studentAnswer = answer.get("answer");
                
                WorksheetQuestion question = questionRepository.findById(questionId)
                        .orElseThrow(() -> new RuntimeException("문제를 찾을 수 없습니다"));
                
                boolean isCorrect = checkAnswer(question, studentAnswer);
                
                SubmissionAnswer submissionAnswer = SubmissionAnswer.builder()
                        .submission(submission)
                        .question(question)
                        .studentAnswer(studentAnswer)
                        .isCorrect(isCorrect)
                        .build();
                
                answerRepository.save(submissionAnswer);
                
                if (isCorrect) {
                    correctCount++;
                    totalPoints += (question.getPoints() != null ? question.getPoints() : 10);
                }
                
                Map<String, Object> resultItem = new HashMap<>();
                resultItem.put("questionNumber", question.getQuestionNumber());
                resultItem.put("questionText", question.getQuestionText());
                resultItem.put("studentAnswer", studentAnswer);
                resultItem.put("correctAnswer", question.getCorrectAnswer());
                resultItem.put("isCorrect", isCorrect);
                results.add(resultItem);
            }
            
            submission.setScore(totalPoints);
            submission.setCorrectCount(correctCount);
            submission.setTotalQuestions(answers.size());
            submissionRepository.save(submission);
            
            student.setExp(student.getExp() + totalPoints);
            student.setTotalCorrect(student.getTotalCorrect() + correctCount);
            student.setTotalWrong(student.getTotalWrong() + (answers.size() - correctCount));
            student.setPoints(student.getPoints() + totalPoints);
            
            while (student.getExp() >= student.getLevel() * 100) {
                student.setExp(student.getExp() - (student.getLevel() * 100));
                student.setLevel(student.getLevel() + 1);
            }
            
            studentRepository.save(student);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("submissionId", submission.getId());
            response.put("score", totalPoints);
            response.put("correctCount", correctCount);
            response.put("totalQuestions", answers.size());
            response.put("percentage", (int)((correctCount * 100.0) / answers.size()));
            response.put("results", results);
            response.put("student", Map.of(
                "level", student.getLevel(),
                "exp", student.getExp(),
                "points", student.getPoints()
            ));
            
            log.info("Submission completed - Score: {}, Correct: {}/{}", 
                totalPoints, correctCount, answers.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to submit worksheet", e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    private boolean checkAnswer(WorksheetQuestion question, String studentAnswer) {
        if (question.getCorrectAnswer() == null || studentAnswer == null) {
            return false;
        }
        
        String correct = question.getCorrectAnswer().trim();
        String student = studentAnswer.trim();
        
        log.info("Checking answer - Question: {}, Correct: '{}', Student: '{}', Match: {}", 
            question.getQuestionNumber(), correct, student, correct.equals(student));
        
        return correct.equals(student);
    }

    @GetMapping("/{submissionId}")
    public ResponseEntity<Map<String, Object>> getSubmission(@PathVariable String submissionId) {
        try {
            StudentSubmission submission = submissionRepository.findById(submissionId)
                    .orElseThrow(() -> new RuntimeException("제출 기록을 찾을 수 없습니다"));
            
            List<SubmissionAnswer> answers = answerRepository.findBySubmission(submission);
            
            Map<String, Object> response = new HashMap<>();
            response.put("submissionId", submission.getId());
            response.put("score", submission.getScore());
            response.put("correctCount", submission.getCorrectCount());
            response.put("totalQuestions", submission.getTotalQuestions());
            response.put("submittedAt", submission.getSubmittedAt());
            
            List<Map<String, Object>> answerList = new ArrayList<>();
            for (SubmissionAnswer answer : answers) {
                Map<String, Object> item = new HashMap<>();
                item.put("questionNumber", answer.getQuestion().getQuestionNumber());
                item.put("questionText", answer.getQuestion().getQuestionText());
                item.put("studentAnswer", answer.getStudentAnswer());
                item.put("correctAnswer", answer.getQuestion().getCorrectAnswer());
                item.put("isCorrect", answer.getIsCorrect());
                answerList.add(item);
            }
            
            response.put("answers", answerList);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to get submission", e);
            return ResponseEntity.status(404).body(new HashMap<>());
        }
    }
}
