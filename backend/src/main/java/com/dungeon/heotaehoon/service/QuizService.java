package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class QuizService {
    private final QuizRepository quizRepository;
    private final StudentRepository studentRepository;
    private final QuizResultRepository quizResultRepository;
    private final RageMessageService rageMessageService;
    private final BossRepository bossRepository;
    private final LessonRepository lessonRepository;

    @Transactional
    public Map<String, Object> submitAnswer(String quizId, String studentId, String selectedAnswer) {
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("퀴즈를 찾을 수 없습니다"));
        
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

        boolean isCorrect = quiz.getCorrectAnswer().equals(selectedAnswer);
        
        QuizResult result = QuizResult.builder()
                .quiz(quiz)
                .student(student)
                .selectedAnswer(selectedAnswer)
                .isCorrect(isCorrect)
                .submittedAt(LocalDateTime.now())
                .build();
        
        quizResultRepository.save(result);
        
        Map<String, Object> response = new HashMap<>();
        response.put("isCorrect", isCorrect);
        response.put("correctAnswer", quiz.getCorrectAnswer());
        response.put("explanation", quiz.getExplanation());
        
        if (isCorrect) {
            int expGain = 10;
            student.setExp(student.getExp() + expGain);
            student.setTotalCorrect(student.getTotalCorrect() + 1);
            student.setPoints(student.getPoints() + 10);
            
            while (student.getExp() >= student.getLevel() * 100) {
                student.setExp(student.getExp() - (student.getLevel() * 100));
                student.setLevel(student.getLevel() + 1);
                response.put("levelUp", true);
                response.put("newLevel", student.getLevel());
            }
            
            response.put("expGain", expGain);
            response.put("message", rageMessageService.getPraiseMessage());
        } else {
            student.setTotalWrong(student.getTotalWrong() + 1);
            student.setMentalGauge(Math.max(0, student.getMentalGauge() - 10));
            
            response.put("rageMessage", rageMessageService.getRageMessage());
            response.put("mentalGauge", student.getMentalGauge());
        }
        
        studentRepository.save(student);
        
        response.put("student", student);
        
        return response;
    }

    public List<Quiz> getQuizzesByBoss(String bossId) {
        return quizRepository.findByBossId(bossId);
    }

    public List<Quiz> getQuizzesByLesson(String lessonId) {
        return quizRepository.findByLessonId(lessonId);
    }

    @Transactional
    public Quiz createQuiz(String lessonId, String bossId, Map<String, Object> quizData) {
        Boss boss = null;
        Lesson lesson = null;
        
        if (bossId != null) {
            boss = bossRepository.findById(bossId).orElse(null);
        }
        
        if (lessonId != null) {
            lesson = lessonRepository.findById(lessonId).orElse(null);
        }
        
        Quiz quiz = Quiz.builder()
                .boss(boss)
                .lesson(lesson)
                .question((String) quizData.get("question"))
                .optionA((String) quizData.get("optionA"))
                .optionB((String) quizData.get("optionB"))
                .optionC((String) quizData.get("optionC"))
                .optionD((String) quizData.get("optionD"))
                .correctAnswer((String) quizData.get("correctAnswer"))
                .explanation((String) quizData.get("explanation"))
                .difficultyLevel((Integer) quizData.getOrDefault("difficultyLevel", 1))
                .createdAt(LocalDateTime.now())
                .build();
        
        return quizRepository.save(quiz);
    }
}
