package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class GameService {

    private final StudentRepository studentRepository;
    private final QuizRepository quizRepository;
    private final QuizAttemptRepository quizAttemptRepository;
    private final LessonRepository lessonRepository;
    private final InstructorRepository instructorRepository;
    private final ExpLogRepository expLogRepository;
    private final AIService aiService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public Lesson getTodayLesson() {
        return lessonRepository.findByLessonDateAndIsActive(LocalDate.now(), true)
            .orElse(null);
    }

    @Transactional
    public Map<String, Object> submitAnswer(String studentId, String quizId, String answer) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("Student not found"));
        
        Quiz quiz = quizRepository.findById(quizId)
            .orElseThrow(() -> new RuntimeException("Quiz not found"));

        boolean isCorrect = quiz.getCorrectAnswer().equalsIgnoreCase(answer);
        
        QuizAttempt attempt = QuizAttempt.builder()
            .student(student)
            .quiz(quiz)
            .selectedAnswer(answer)
            .isCorrect(isCorrect)
            .comboCount(0)
            .rageTriggered(false)
            .attemptTime(LocalDateTime.now())
            .build();
        
        quizAttemptRepository.save(attempt);

        Map<String, Object> result = new HashMap<>();
        result.put("isCorrect", isCorrect);
        result.put("correctAnswer", quiz.getCorrectAnswer());
        result.put("explanation", quiz.getExplanation());

        if (isCorrect) {
            int expGained = 10;
            int pointsGained = 5;
            
            student.setExp(student.getExp() + expGained);
            student.setPoints(student.getPoints() + pointsGained);
            student.setTotalCorrect(student.getTotalCorrect() + 1);
            
            if (student.getExp() >= student.getLevel() * 100) {
                student.setExp(student.getExp() - (student.getLevel() * 100));
                student.setLevel(student.getLevel() + 1);
                result.put("levelUp", true);
            }
            
            result.put("expGained", expGained);
            result.put("pointsGained", pointsGained);
            result.put("encouragement", aiService.generatePraise(1));
            
            updateInstructorExp(quiz.getLesson().getInstructor(), true);
            
        } else {
            student.setTotalWrong(student.getTotalWrong() + 1);
            student.setMentalGauge(Math.max(0, student.getMentalGauge() - 5));
            
            String rageMessage = aiService.generateRageMessage(3);
            result.put("rageMessage", rageMessage);
            
            updateInstructorExp(quiz.getLesson().getInstructor(), false);
        }

        studentRepository.save(student);
        
        return result;
    }

    @Transactional
    public void updateInstructorExp(Instructor instructor, boolean studentCorrect) {
        int expGain = studentCorrect ? 5 : 2;
        
        instructor.setExp(instructor.getExp() + expGain);
        
        if (instructor.getExp() >= instructor.getLevel() * 500) {
            instructor.setExp(instructor.getExp() - (instructor.getLevel() * 500));
            instructor.setLevel(instructor.getLevel() + 1);
            instructor.setRageGauge(Math.max(0, instructor.getRageGauge() - 10));
            
            if (instructor.getLevel() >= 10 && !"calm".equals(instructor.getEvolutionStage())) {
                instructor.setEvolutionStage("calm");
            } else if (instructor.getLevel() >= 5 && "normal".equals(instructor.getEvolutionStage())) {
                instructor.setEvolutionStage("angry");
            }
        }
        
        if (!studentCorrect) {
            instructor.setRageGauge(Math.min(100, instructor.getRageGauge() + 3));
        } else {
            instructor.setRageGauge(Math.max(0, instructor.getRageGauge() - 1));
        }
        
        instructorRepository.save(instructor);
        
        ExpLog log = ExpLog.builder()
            .instructor(instructor)
            .expAmount(expGain)
            .expType(studentCorrect ? "student_correct" : "student_wrong")
            .sourceType("quiz_result")
            .createdAt(LocalDateTime.now())
            .build();
        expLogRepository.save(log);
    }

    @Transactional
    public Map<String, Object> generateQuizForLesson(String lessonId) {
        Lesson lesson = lessonRepository.findById(lessonId)
            .orElseThrow(() -> new RuntimeException("Lesson not found"));

        List<Quiz> recentQuizzes = quizRepository.findTop5ByLessonOrderByCreatedAtDesc(lesson);
        
        String previousQuestion = null;
        String previousAnswer = null;
        
        if (!recentQuizzes.isEmpty()) {
            Quiz lastQuiz = recentQuizzes.get(0);
            previousQuestion = lastQuiz.getQuestion();
            previousAnswer = lastQuiz.getCorrectAnswer();
        }

        String aiResponse = aiService.generateQuiz(
            lesson.getTitle(),
            lesson.getSubject(),
            lesson.getDifficultyStars(),
            previousQuestion,
            previousAnswer
        );

        try {
            JsonNode quizNode = objectMapper.readTree(aiResponse);
            
            Quiz quiz = Quiz.builder()
                .lesson(lesson)
                .question(quizNode.get("question").asText())
                .optionA(quizNode.get("optionA").asText())
                .optionB(quizNode.get("optionB").asText())
                .optionC(quizNode.get("optionC").asText())
                .optionD(quizNode.get("optionD").asText())
                .correctAnswer(quizNode.get("correctAnswer").asText())
                .explanation(quizNode.get("explanation").asText())
                .difficultyLevel(lesson.getDifficultyStars())
                .createdAt(LocalDateTime.now())
                .build();
            
            quiz = quizRepository.save(quiz);

            Map<String, Object> result = new HashMap<>();
            result.put("quizId", quiz.getId());
            result.put("question", quiz.getQuestion());
            result.put("optionA", quiz.getOptionA());
            result.put("optionB", quiz.getOptionB());
            result.put("optionC", quiz.getOptionC());
            result.put("optionD", quiz.getOptionD());
            
            return result;
        } catch (Exception e) {
            throw new RuntimeException("퀴즈 파싱 실패: " + e.getMessage());
        }
    }

    public Map<String, Object> getInstructorStats(String instructorId) {
        Instructor instructor = instructorRepository.findById(instructorId)
            .orElseThrow(() -> new RuntimeException("Instructor not found"));

        List<Student> allStudents = studentRepository.findAll();
        int totalCorrect = allStudents.stream().mapToInt(Student::getTotalCorrect).sum();
        int totalWrong = allStudents.stream().mapToInt(Student::getTotalWrong).sum();
        int totalAttempts = totalCorrect + totalWrong;
        
        double successRate = totalAttempts > 0 ? (totalCorrect * 100.0 / totalAttempts) : 0;

        Map<String, Object> stats = new HashMap<>();
        stats.put("instructor", instructor);
        stats.put("totalStudents", allStudents.size());
        stats.put("totalCorrect", totalCorrect);
        stats.put("totalWrong", totalWrong);
        stats.put("successRate", String.format("%.1f%%", successRate));
        stats.put("nextLevelExp", instructor.getLevel() * 500);
        
        return stats;
    }

    public List<Quiz> getQuizzesByLesson(String lessonId) {
        Lesson lesson = lessonRepository.findById(lessonId)
            .orElseThrow(() -> new RuntimeException("Lesson not found"));
        return quizRepository.findByLessonOrderByCreatedAtAsc(lesson);
    }
}
