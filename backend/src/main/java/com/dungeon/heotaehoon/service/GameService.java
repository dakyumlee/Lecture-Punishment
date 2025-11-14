package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.dto.QuizAnswerRequest;
import com.dungeon.heotaehoon.dto.QuizAnswerResponse;
import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class GameService {

    private final QuizRepository quizRepository;
    private final QuizAttemptRepository attemptRepository;
    private final StudentRepository studentRepository;
    private final RageDialogueRepository rageRepository;
    private final ExpLogRepository expLogRepository;
    private final Random random = new Random();

    @Transactional
    public QuizAnswerResponse submitQuizAnswer(String quizId, QuizAnswerRequest request) {
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("퀴즈를 찾을 수 없습니다"));

        Student student = studentRepository.findById(request.getStudentId().toString())
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

        boolean isCorrect = quiz.getCorrectAnswer().equalsIgnoreCase(request.getSelectedAnswer().trim());

        QuizAttempt attempt = QuizAttempt.builder()
                .quiz(quiz)
                .student(student)
                .selectedAnswer(request.getSelectedAnswer())
                .isCorrect(isCorrect)
                .attemptTime(LocalDateTime.now())
                .build();

        attemptRepository.save(attempt);

        if (isCorrect) {
            student.setExp(student.getExp() + 10);
            student.setTotalCorrect(student.getTotalCorrect() + 1);
            checkLevelUp(student);
        } else {
            student.setTotalWrong(student.getTotalWrong() + 1);
            student.setMentalGauge(Math.max(0, student.getMentalGauge() - 10));
        }

        studentRepository.save(student);

        return QuizAnswerResponse.builder()
                .isCorrect(isCorrect)
                .correctAnswer(quiz.getCorrectAnswer())
                .expGained(isCorrect ? 10 : 0)
                .studentLevel(student.getLevel())
                .studentExp(student.getExp())
                .build();
    }

    private void checkLevelUp(Student student) {
        int requiredExp = student.getLevel() * 100;
        if (student.getExp() >= requiredExp) {
            student.setLevel(student.getLevel() + 1);
            student.setExp(student.getExp() - requiredExp);
        }
    }

    public Map<String, String> getRandomRageDialogue() {
        long count = rageRepository.count();
        if (count == 0) {
            Map<String, String> defaultRage = new HashMap<>();
            defaultRage.put("text", "복습 안 했구나?");
            defaultRage.put("intensity", "5");
            return defaultRage;
        }

        int randomIndex = random.nextInt((int) count);
        RageDialogue rage = rageRepository.findAll().get(randomIndex);

        Map<String, String> result = new HashMap<>();
        result.put("text", rage.getDialogueText());
        result.put("intensity", String.valueOf(rage.getIntensityLevel()));
        return result;
    }
}
