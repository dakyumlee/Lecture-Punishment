package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
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
    private final SimilarityService similarityService;

    public List<PdfWorksheet> getAllWorksheets() {
        return worksheetRepository.findAll();
    }

    public List<PdfWorksheet> getAllActiveWorksheets() {
        return worksheetRepository.findAll();
    }

    public PdfWorksheet getWorksheetById(String id) {
        return worksheetRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("학습지를 찾을 수 없습니다"));
    }

    public List<WorksheetQuestion> getQuestionsByWorksheetId(String worksheetId) {
        PdfWorksheet worksheet = getWorksheetById(worksheetId);
        return questionRepository.findByWorksheetOrderByQuestionNumberAsc(worksheet);
    }

    public Map<String, List<PdfWorksheet>> getWorksheetsGroupedByCategory() {
        List<PdfWorksheet> worksheets = worksheetRepository.findAll();
        return worksheets.stream()
                .collect(Collectors.groupingBy(w -> w.getCategory() != null ? w.getCategory() : "기타"));
    }

    public Map<String, Object> getWorksheetWithQuestions(String worksheetId) {
        PdfWorksheet worksheet = getWorksheetById(worksheetId);
        List<WorksheetQuestion> questions = getQuestionsByWorksheetId(worksheetId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("worksheet", worksheet);
        result.put("questions", questions);
        return result;
    }

    @Transactional
    public PdfWorksheet createWorksheet(String title, String description, String category, MultipartFile file) throws IOException {
        PdfWorksheet worksheet = PdfWorksheet.builder()
                .title(title)
                .description(description)
                .category(category)
                .fileName(file.getOriginalFilename())
                .pdfContent(file.getBytes())
                .createdAt(LocalDateTime.now())
                .build();
        return worksheetRepository.save(worksheet);
    }

    @Transactional
    public Map<String, Object> createWorksheetWithQuestions(String title, String description, List<Map<String, Object>> questionsList) {
        PdfWorksheet worksheet = PdfWorksheet.builder()
                .title(title)
                .description(description)
                .category("일반")
                .fileName(title + ".json")
                .createdAt(LocalDateTime.now())
                .build();
        
        worksheet = worksheetRepository.save(worksheet);
        
        List<WorksheetQuestion> savedQuestions = new ArrayList<>();
        
        for (Map<String, Object> questionData : questionsList) {
            Integer questionNumber = (Integer) questionData.get("questionNumber");
            String questionType = (String) questionData.get("questionType");
            String questionText = (String) questionData.get("questionText");
            String correctAnswer = (String) questionData.get("correctAnswer");
            String optionA = (String) questionData.get("optionA");
            String optionB = (String) questionData.get("optionB");
            String optionC = (String) questionData.get("optionC");
            String optionD = (String) questionData.get("optionD");
            Integer points = (Integer) questionData.get("points");
            
            WorksheetQuestion question = WorksheetQuestion.builder()
                    .worksheet(worksheet)
                    .questionNumber(questionNumber)
                    .questionType(questionType)
                    .questionText(questionText)
                    .correctAnswer(correctAnswer)
                    .optionA(optionA)
                    .optionB(optionB)
                    .optionC(optionC)
                    .optionD(optionD)
                    .points(points != null ? points : 10)
                    .allowPartial(false)
                    .similarityThreshold(0.85)
                    .createdAt(LocalDateTime.now())
                    .build();
            
            savedQuestions.add(questionRepository.save(question));
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("worksheet", worksheet);
        result.put("questions", savedQuestions);
        result.put("id", worksheet.getId());
        result.put("title", worksheet.getTitle());
        
        return result;
    }

    @Transactional
    public Map<String, Object> submitWorksheet(String studentId, String worksheetId, List<Map<String, String>> answersList) {
        PdfWorksheet worksheet = getWorksheetById(worksheetId);
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

        Map<String, String> answersMap = new HashMap<>();
        for (Map<String, String> answerEntry : answersList) {
            answersMap.put(answerEntry.get("questionId"), answerEntry.get("answer"));
        }

        List<WorksheetQuestion> questions = questionRepository.findByWorksheetOrderByQuestionNumberAsc(worksheet);

        StudentSubmission submission = StudentSubmission.builder()
                .student(student)
                .worksheet(worksheet)
                .submittedAt(LocalDateTime.now())
                .createdAt(LocalDateTime.now())
                .totalScore(0)
                .maxScore(questions.stream().mapToInt(WorksheetQuestion::getPoints).sum())
                .build();

        submission = submissionRepository.save(submission);

        int totalScore = 0;
        List<SubmissionAnswer> submissionAnswers = new ArrayList<>();

        for (WorksheetQuestion question : questions) {
            String studentAnswer = answersMap.getOrDefault(question.getId(), "");

            boolean isCorrect = evaluateAnswer(question, studentAnswer);
            int pointsEarned = isCorrect ? question.getPoints() : 0;
            totalScore += pointsEarned;

            SubmissionAnswer answer = SubmissionAnswer.builder()
                    .submission(submission)
                    .question(question)
                    .studentAnswer(studentAnswer)
                    .isCorrect(isCorrect)
                    .pointsEarned(pointsEarned)
                    .createdAt(LocalDateTime.now())
                    .build();

            submissionAnswers.add(answer);
        }

        answerRepository.saveAll(submissionAnswers);

        submission.setTotalScore(totalScore);
        submission = submissionRepository.save(submission);

        Map<String, Object> result = new HashMap<>();
        result.put("submission", submission);
        result.put("totalScore", totalScore);
        result.put("maxScore", submission.getMaxScore());
        result.put("correctCount", submissionAnswers.stream().filter(SubmissionAnswer::getIsCorrect).count());
        return result;
    }

    private boolean evaluateAnswer(WorksheetQuestion question, String studentAnswer) {
        if (studentAnswer == null || studentAnswer.trim().isEmpty()) {
            return false;
        }

        String correctAnswer = question.getCorrectAnswer().toLowerCase().trim();
        String normalizedStudentAnswer = studentAnswer.toLowerCase().trim();

        if ("multiple_choice".equals(question.getQuestionType())) {
            return correctAnswer.equals(normalizedStudentAnswer);
        }

        if (correctAnswer.equals(normalizedStudentAnswer)) {
            return true;
        }

        if (question.getAllowPartial()) {
            double similarity = similarityService.calculateSimilarity(correctAnswer, normalizedStudentAnswer);
            double threshold = question.getSimilarityThreshold() != null 
                    ? question.getSimilarityThreshold().doubleValue() 
                    : 0.85;
            return similarity >= threshold;
        }

        return false;
    }

    public Map<String, Object> getWorksheetStats(String worksheetId) {
        PdfWorksheet worksheet = getWorksheetById(worksheetId);
        List<StudentSubmission> submissions = submissionRepository.findByWorksheet(worksheet);

        if (submissions.isEmpty()) {
            return Map.of(
                    "totalSubmissions", 0,
                    "averageScore", 0.0,
                    "highestScore", 0,
                    "lowestScore", 0
            );
        }

        double averageScore = submissions.stream()
                .mapToInt(StudentSubmission::getTotalScore)
                .average()
                .orElse(0.0);

        int highestScore = submissions.stream()
                .mapToInt(StudentSubmission::getTotalScore)
                .max()
                .orElse(0);

        int lowestScore = submissions.stream()
                .mapToInt(StudentSubmission::getTotalScore)
                .min()
                .orElse(0);

        return Map.of(
                "totalSubmissions", submissions.size(),
                "averageScore", averageScore,
                "highestScore", highestScore,
                "lowestScore", lowestScore
        );
    }

    public List<StudentSubmission> getStudentSubmissions(String studentId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
        return submissionRepository.findByStudentOrderBySubmittedAtDesc(student);
    }

    public Map<String, Object> getQuestionAnalysis(String worksheetId) {
        PdfWorksheet worksheet = getWorksheetById(worksheetId);
        List<WorksheetQuestion> questions = questionRepository.findByWorksheetOrderByQuestionNumberAsc(worksheet);
        List<SubmissionAnswer> allAnswers = new ArrayList<>();

        List<StudentSubmission> submissions = submissionRepository.findByWorksheet(worksheet);
        for (StudentSubmission submission : submissions) {
            allAnswers.addAll(answerRepository.findBySubmission(submission));
        }

        Map<String, Map<String, Object>> questionStats = new HashMap<>();

        for (WorksheetQuestion question : questions) {
            List<SubmissionAnswer> questionAnswers = allAnswers.stream()
                    .filter(a -> a.getQuestion().getId().equals(question.getId()))
                    .collect(Collectors.toList());

            long correctCount = questionAnswers.stream()
                    .filter(SubmissionAnswer::getIsCorrect)
                    .count();

            double correctRate = questionAnswers.isEmpty() 
                    ? 0.0 
                    : (correctCount * 100.0) / questionAnswers.size();

            Map<String, Object> stats = new HashMap<>();
            stats.put("questionNumber", question.getQuestionNumber());
            stats.put("questionText", question.getQuestionText());
            stats.put("totalAttempts", questionAnswers.size());
            stats.put("correctCount", correctCount);
            stats.put("correctRate", correctRate);

            questionStats.put(question.getId(), stats);
        }

        return Map.of("questions", questionStats);
    }

    @Transactional
    public void deleteWorksheet(String worksheetId) {
        PdfWorksheet worksheet = getWorksheetById(worksheetId);
        
        List<StudentSubmission> submissions = submissionRepository.findByWorksheet(worksheet);
        for (StudentSubmission submission : submissions) {
            answerRepository.deleteAll(answerRepository.findBySubmission(submission));
        }
        submissionRepository.deleteAll(submissions);
        
        List<WorksheetQuestion> questions = questionRepository.findByWorksheetOrderByQuestionNumberAsc(worksheet);
        questionRepository.deleteAll(questions);
        
        worksheetRepository.delete(worksheet);
    }

    @Transactional
    public WorksheetQuestion addQuestion(String worksheetId, WorksheetQuestion question) {
        PdfWorksheet worksheet = getWorksheetById(worksheetId);
        question.setWorksheet(worksheet);
        question.setCreatedAt(LocalDateTime.now());
        return questionRepository.save(question);
    }

    @Transactional
    public WorksheetQuestion updateQuestion(String questionId, WorksheetQuestion questionDetails) {
        WorksheetQuestion question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("문제를 찾을 수 없습니다"));

        question.setQuestionNumber(questionDetails.getQuestionNumber());
        question.setQuestionType(questionDetails.getQuestionType());
        question.setQuestionText(questionDetails.getQuestionText());
        question.setCorrectAnswer(questionDetails.getCorrectAnswer());
        question.setOptionA(questionDetails.getOptionA());
        question.setOptionB(questionDetails.getOptionB());
        question.setOptionC(questionDetails.getOptionC());
        question.setOptionD(questionDetails.getOptionD());
        question.setPoints(questionDetails.getPoints());
        question.setAllowPartial(questionDetails.getAllowPartial());
        question.setSimilarityThreshold(questionDetails.getSimilarityThreshold());

        return questionRepository.save(question);
    }

    @Transactional
    public void deleteQuestion(String questionId) {
        WorksheetQuestion question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("문제를 찾을 수 없습니다"));
        
        List<SubmissionAnswer> answers = answerRepository.findByQuestion(question);
        answerRepository.deleteAll(answers);
        
        questionRepository.delete(question);
    }

    public StudentSubmission getSubmissionById(String submissionId) {
        return submissionRepository.findById(submissionId)
                .orElseThrow(() -> new RuntimeException("제출을 찾을 수 없습니다"));
    }

    public List<SubmissionAnswer> getSubmissionAnswers(String submissionId) {
        return answerRepository.findBySubmission_Id(submissionId);
    }
}
