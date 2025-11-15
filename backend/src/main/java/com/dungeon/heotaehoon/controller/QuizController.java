package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Quiz;
import com.dungeon.heotaehoon.repository.QuizRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/quizzes")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class QuizController {

    private final QuizRepository quizRepository;

    @GetMapping
    public ResponseEntity<List<Quiz>> getAllQuizzes() {
        return ResponseEntity.ok(quizRepository.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Quiz> getQuizById(@PathVariable String id) {
        return quizRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/boss/{bossId}")
    public ResponseEntity<List<Quiz>> getQuizzesByBoss(@PathVariable String bossId) {
        return ResponseEntity.ok(quizRepository.findByBossId(bossId));
    }

    @GetMapping("/lesson/{lessonId}")
    public ResponseEntity<List<Quiz>> getQuizzesByLesson(@PathVariable String lessonId) {
        return ResponseEntity.ok(quizRepository.findByLessonId(lessonId));
    }
}