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
@Transactional
public class WorksheetService {

    private final PdfWorksheetRepository worksheetRepository;
    private final WorksheetQuestionRepository questionRepository;
    private final StudentSubmissionRepository submissionRepository;
    private final SubmissionAnswerRepository answerRepository;
    private final StudentRepository studentRepository;

    public PdfWorksheet createWorksheet(String title, String description, String category, MultipartFile pdfFile) throws IOException {
        PdfWorksheet worksheet = PdfWorksheet.builder()
            .title(title)
            .description(description)
            .category(category)
            .pdfContent(pdfFile.getBytes())
            .fileName(pdfFile.getOriginalFilename())
            .build();
        
        return worksheetRepository.save(worksheet);
    }

    public WorksheetQuestion addQuestion(String worksheetId, WorksheetQuestion question) {
        PdfWorksheet worksheet = worksheetRepository.findById(worksheetId)
            .orElseThrow(() -> new RuntimeException("Worksheet not found"));
        
        question.setWorksheet(worksheet);
        question.setQuestionNumber(worksheet.getTotalQuestions() + 1);
        
        WorksheetQuestion saved = questionRepository.save(question);
        
        worksheet.setTotalQuestions(worksheet.getTotalQuestions() + 1);
        worksheetRepository.save(worksheet);
        
        return saved;
    }

    public Map<String, Object> getWorksheetWithQuestions(String worksheetId) {
        PdfWorksheet worksheet = worksheetRepository.findById(worksheetId)
            .orElseThrow(() -> new RuntimeException("Worksheet not found"));
        
        List<WorksheetQuestion> questions = questionRepository.findByWorksheetOrderByQuestionNumberAsc(worksheet);
        
        Map<String, Object> result = new HashMap<>();
        result.put("worksheet", worksheet);
        result.put("questions", questions);
        
        return result;
    }

    public Map<String, Object> submitWorksheet(String studentId, String worksheetId, List<Map<String, String>> answers) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("Student not found"));
        
        PdfWorksheet worksheet = worksheetRepository.findById(worksheetId)
            .orElseThrow(() -> new RuntimeException("Worksheet not found"));
        
        StudentSubmission submission = StudentSubmission.builder()
            .student(student)
            .worksheet(worksheet)
            .submittedAt(LocalDateTime.now())
            .build();
        submission = submissionRepository.save(submission);
        
        int correctCount = 0;
        int wrongCount = 0;
        int totalScore = 0;
        int maxScore = 0;
        
        for (Map<String, String> answerData : answers) {
            String questionId = answerData.get("questionId");
            String studentAnswer = answerData.get("answer");
            
            WorksheetQuestion question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("Question not found"));
            
            boolean isCorrect = checkAnswer(question, studentAnswer);
            
            SubmissionAnswer answer = SubmissionAnswer.builder()
                .submission(submission)
                .question(question)
                .studentAnswer(studentAnswer)
                .isCorrect(isCorrect)
                .build();
            answerRepository.save(answer);
            
            maxScore += question.getPoints();
            if (isCorrect) {
                correctCount++;
                totalScore += question.getPoints();
            } else {
                wrongCount++;
            }
        }
        
        submission.setTotalScore(totalScore);
        submission.setMaxScore(maxScore);
        submissionRepository.save(submission);
        
        int expGained = correctCount * 10;
        int pointsGained = totalScore;
        student.setExp(student.getExp() + expGained);
        student.setPoints(student.getPoints() + pointsGained);
        student.setTotalCorrect(student.getTotalCorrect() + correctCount);
        student.setTotalWrong(student.getTotalWrong() + wrongCount);
        
        boolean leveledUp = false;
        int newLevel = student.getLevel();
        while (student.getExp() >= student.getLevel() * 100) {
            student.setExp(student.getExp() - student.getLevel() * 100);
            student.setLevel(student.getLevel() + 1);
            leveledUp = true;
            newLevel = student.getLevel();
        }
        
        studentRepository.save(student);
        
        Map<String, Object> result = new HashMap<>();
        result.put("submissionId", submission.getId());
        result.put("totalScore", totalScore);
        result.put("maxScore", maxScore);
        result.put("correctCount", correctCount);
        result.put("wrongCount", wrongCount);
        result.put("percentage", maxScore > 0 ? (totalScore * 100 / maxScore) : 0);
        result.put("expGained", expGained);
        result.put("pointsGained", pointsGained);
        result.put("leveledUp", leveledUp);
        result.put("newLevel", newLevel);
        
        if (wrongCount > 0) {
            String[] rageMessages = {
                "너는 복습을 했니? 했으면 이럴 리가 없지 ㅋㅋ",
                "목졸라뿐다",
                "니대가리로 이해가 가긴하겠니",
                "이게 뭐야... 이게 답이야?",
                "나 화났어"
            };
            result.put("rageMessage", rageMessages[new Random().nextInt(rageMessages.length)]);
        }
        
        if (wrongCount == 0) {
            String[] encouragements = {
                "오 잘했네?",
                "이 정도면 인정이야",
                "완벽하잖아!",
                "역시 내 제자야"
            };
            result.put("encouragement", encouragements[new Random().nextInt(encouragements.length)]);
        }
        
        return result;
    }

    private boolean checkAnswer(WorksheetQuestion question, String studentAnswer) {
        if (question.getQuestionType().equals("multiple_choice")) {
            return question.getCorrectAnswer().trim().equalsIgnoreCase(studentAnswer.trim());
        } else {
            String correct = question.getCorrectAnswer().toLowerCase().trim();
            String student = studentAnswer.toLowerCase().trim();
            return correct.equals(student) || correct.contains(student) || student.contains(correct);
        }
    }

    public List<PdfWorksheet> getAllActiveWorksheets() {
        return worksheetRepository.findByIsActiveTrue();
    }

    public List<PdfWorksheet> getWorksheetsByCategory(String category) {
        return worksheetRepository.findByCategoryAndIsActive(category, true);
    }

    public Map<String, List<PdfWorksheet>> getWorksheetsGroupedByCategory() {
        List<PdfWorksheet> allWorksheets = worksheetRepository.findByIsActiveTrue();
        return allWorksheets.stream()
            .collect(Collectors.groupingBy(PdfWorksheet::getCategory));
    }

    public List<StudentSubmission> getStudentSubmissions(String studentId) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("Student not found"));
        return submissionRepository.findByStudentOrderBySubmittedAtDesc(student);
    }
}

    public PdfWorksheet getWorksheetById(String worksheetId) {
        return worksheetRepository.findById(worksheetId)
            .orElseThrow(() -> new RuntimeException("Worksheet not found"));
    }

    public void deleteWorksheet(String worksheetId) {
        PdfWorksheet worksheet = worksheetRepository.findById(worksheetId)
            .orElseThrow(() -> new RuntimeException("Worksheet not found"));
        
        List<WorksheetQuestion> questions = questionRepository.findByWorksheetOrderByQuestionNumberAsc(worksheet);
        for (WorksheetQuestion question : questions) {
            List<SubmissionAnswer> answers = answerRepository.findByQuestion(question);
            answerRepository.deleteAll(answers);
        }
        
        questionRepository.deleteAll(questions);
        
        List<StudentSubmission> submissions = submissionRepository.findByWorksheet(worksheet);
        submissionRepository.deleteAll(submissions);
        
        worksheet.setIsActive(false);
        worksheetRepository.save(worksheet);
    }
}
