package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WorksheetService {

    private final PdfWorksheetRepository worksheetRepository;
    private final WorksheetQuestionRepository questionRepository;
    private final StudentSubmissionRepository submissionRepository;
    private final SubmissionAnswerRepository answerRepository;
    private final StudentRepository studentRepository;
    private final InstructorRepository instructorRepository;
    private final ExpLogRepository expLogRepository;
    private final SimilarityService similarityService;
    private final AIService aiService;

    @Transactional
    public PdfWorksheet createWorksheet(Map<String, Object> worksheetData) {
        Instructor instructor = instructorRepository.findByName("허태훈")
            .orElseThrow(() -> new RuntimeException("Instructor not found"));

        PdfWorksheet worksheet = PdfWorksheet.builder()
            .instructor(instructor)
            .title((String) worksheetData.get("title"))
            .description((String) worksheetData.get("description"))
            .subject((String) worksheetData.get("subject"))
            .category((String) worksheetData.get("category"))
            .difficultyLevel((Integer) worksheetData.get("difficultyLevel"))
            .pdfUrl((String) worksheetData.get("pdfUrl"))
            .isActive(true)
            .build();

        return worksheetRepository.save(worksheet);
    }

    @Transactional
    public WorksheetQuestion addQuestion(String worksheetId, Map<String, Object> questionData) {
        PdfWorksheet worksheet = worksheetRepository.findById(worksheetId)
            .orElseThrow(() -> new RuntimeException("Worksheet not found"));

        WorksheetQuestion question = WorksheetQuestion.builder()
            .worksheet(worksheet)
            .questionNumber((Integer) questionData.get("questionNumber"))
            .questionType((String) questionData.get("questionType"))
            .questionText((String) questionData.get("questionText"))
            .correctAnswer((String) questionData.get("correctAnswer"))
            .optionA((String) questionData.get("optionA"))
            .optionB((String) questionData.get("optionB"))
            .optionC((String) questionData.get("optionC"))
            .optionD((String) questionData.get("optionD"))
            .points((Integer) questionData.getOrDefault("points", 10))
            .allowPartial((Boolean) questionData.getOrDefault("allowPartial", false))
            .similarityThreshold(new BigDecimal(questionData.getOrDefault("similarityThreshold", "0.85").toString()))
            .build();

        WorksheetQuestion saved = questionRepository.save(question);

        worksheet.setTotalQuestions(worksheet.getTotalQuestions() + 1);
        worksheetRepository.save(worksheet);

        return saved;
    }

    @Transactional
    public Map<String, Object> submitWorksheet(String studentId, String worksheetId, List<Map<String, String>> answers) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("Student not found"));

        PdfWorksheet worksheet = worksheetRepository.findById(worksheetId)
            .orElseThrow(() -> new RuntimeException("Worksheet not found"));

        Optional<StudentSubmission> existingSubmission = 
            submissionRepository.findByStudentAndWorksheet(student, worksheet);
        
        if (existingSubmission.isPresent()) {
            throw new RuntimeException("이미 제출한 문제지입니다");
        }

        StudentSubmission submission = StudentSubmission.builder()
            .student(student)
            .worksheet(worksheet)
            .isGraded(false)
            .build();

        submission = submissionRepository.save(submission);

        int totalScore = 0;
        int maxScore = 0;
        int correctCount = 0;
        int wrongCount = 0;

        List<SubmissionAnswer> submissionAnswers = new ArrayList<>();

        for (Map<String, String> answerData : answers) {
            String questionId = answerData.get("questionId");
            String studentAnswer = answerData.get("answer");

            WorksheetQuestion question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("Question not found"));

            maxScore += question.getPoints();

            boolean isCorrect = false;
            int pointsEarned = 0;
            BigDecimal similarity = BigDecimal.ZERO;

            if ("multiple_choice".equals(question.getQuestionType())) {
                isCorrect = question.getCorrectAnswer().equalsIgnoreCase(studentAnswer.trim());
                pointsEarned = isCorrect ? question.getPoints() : 0;
                similarity = isCorrect ? BigDecimal.ONE : BigDecimal.ZERO;
            } else if ("subjective".equals(question.getQuestionType())) {
                similarity = similarityService.calculateLevenshteinSimilarity(
                    studentAnswer, 
                    question.getCorrectAnswer()
                );
                
                isCorrect = similarityService.isAnswerCorrect(
                    studentAnswer, 
                    question.getCorrectAnswer(), 
                    question.getSimilarityThreshold()
                );

                if (isCorrect) {
                    pointsEarned = question.getPoints();
                } else if (question.getAllowPartial() && similarity.compareTo(new BigDecimal("0.70")) >= 0) {
                    pointsEarned = (int) (question.getPoints() * similarity.doubleValue());
                }
            }

            if (isCorrect) {
                correctCount++;
            } else {
                wrongCount++;
            }

            totalScore += pointsEarned;

            SubmissionAnswer submissionAnswer = SubmissionAnswer.builder()
                .submission(submission)
                .question(question)
                .studentAnswer(studentAnswer)
                .isCorrect(isCorrect)
                .pointsEarned(pointsEarned)
                .similarityScore(similarity)
                .build();

            submissionAnswers.add(submissionAnswer);
        }

        answerRepository.saveAll(submissionAnswers);

        submission.setTotalScore(totalScore);
        submission.setMaxScore(maxScore);
        submission.setPercentage(
            maxScore > 0 
                ? BigDecimal.valueOf(totalScore * 100.0 / maxScore).setScale(2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO
        );
        submission.setIsGraded(true);
        submission.setGradedAt(LocalDateTime.now());

        submissionRepository.save(submission);

        int expGained = correctCount * 10;
        int pointsGained = correctCount * 5;
        
        student.setExp(student.getExp() + expGained);
        student.setPoints(student.getPoints() + pointsGained);
        student.setTotalCorrect(student.getTotalCorrect() + correctCount);
        student.setTotalWrong(student.getTotalWrong() + wrongCount);

        boolean leveledUp = false;
        if (student.getExp() >= student.getLevel() * 100) {
            student.setExp(student.getExp() - (student.getLevel() * 100));
            student.setLevel(student.getLevel() + 1);
            leveledUp = true;
        }

        studentRepository.save(student);

        Map<String, Object> result = new HashMap<>();
        result.put("submissionId", submission.getId());
        result.put("totalScore", totalScore);
        result.put("maxScore", maxScore);
        result.put("percentage", submission.getPercentage());
        result.put("correctCount", correctCount);
        result.put("wrongCount", wrongCount);
        result.put("expGained", expGained);
        result.put("pointsGained", pointsGained);
        result.put("leveledUp", leveledUp);
        result.put("newLevel", student.getLevel());
        
        if (wrongCount > 0) {
            String rageMessage = aiService.generateRageMessage(Math.min(wrongCount, 5));
            result.put("rageMessage", rageMessage);
        } else {
            result.put("encouragement", aiService.generatePraise(1));
        }

        return result;
    }

    public List<PdfWorksheet> getWorksheetsByCategory(String category) {
        return worksheetRepository.findByCategoryAndIsActiveTrue(category, true);
    }

    public List<PdfWorksheet> getAllActiveWorksheets() {
        return worksheetRepository.findByIsActiveTrue();
    }

    public Map<String, Object> getWorksheetWithQuestions(String worksheetId) {
        PdfWorksheet worksheet = worksheetRepository.findById(worksheetId)
            .orElseThrow(() -> new RuntimeException("Worksheet not found"));

        List<WorksheetQuestion> questions = questionRepository.findByWorksheetIdOrderByQuestionNumber(worksheetId);

        Map<String, Object> result = new HashMap<>();
        result.put("worksheet", worksheet);
        result.put("questions", questions);

        return result;
    }

    public List<Map<String, Object>> getStudentSubmissions(String studentId) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("Student not found"));

        List<StudentSubmission> submissions = submissionRepository.findByStudentOrderBySubmissionDateDesc(student);

        return submissions.stream().map(submission -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", submission.getId());
            map.put("worksheetTitle", submission.getWorksheet().getTitle());
            map.put("category", submission.getWorksheet().getCategory());
            map.put("totalScore", submission.getTotalScore());
            map.put("maxScore", submission.getMaxScore());
            map.put("percentage", submission.getPercentage());
            map.put("submissionDate", submission.getSubmissionDate());
            return map;
        }).collect(Collectors.toList());
    }
}
