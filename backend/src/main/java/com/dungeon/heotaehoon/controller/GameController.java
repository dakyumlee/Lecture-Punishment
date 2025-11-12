package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import com.dungeon.heotaehoon.service.GameService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.*;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class GameController {
    
    private final GameService gameService;
    private final StudentRepository studentRepository;
    private final InstructorRepository instructorRepository;
    private final LessonRepository lessonRepository;
    private final BossRepository bossRepository;
    private final QuizRepository quizRepository;
    
    @GetMapping("/students/username/{username}")
    public ResponseEntity<Student> getStudentByUsername(@PathVariable String username) {
        return studentRepository.findByUsername(username)
            .map(ResponseEntity::ok)
            .orElseThrow(() -> new RuntimeException("Student not found"));
    }
    
    @GetMapping("/students/{id}")
    public ResponseEntity<Student> getStudentById(@PathVariable String id) {
        return studentRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElseThrow(() -> new RuntimeException("Student not found"));
    }
    
    @PostMapping("/students")
    public ResponseEntity<Student> createStudent(@RequestBody Student student) {
        Student saved = studentRepository.save(student);
        return ResponseEntity.ok(saved);
    }
    
    @GetMapping("/instructors/name/{name}")
    public ResponseEntity<Instructor> getInstructorByName(@PathVariable String name) {
        return instructorRepository.findByName(name)
            .map(ResponseEntity::ok)
            .orElseThrow(() -> new RuntimeException("Instructor not found"));
    }
    
    @GetMapping("/lessons/today")
    public ResponseEntity<Lesson> getTodayLesson() {
        Lesson lesson = gameService.getTodayLesson();
        if (lesson == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(lesson);
    }
    
    @GetMapping("/bosses/lesson/{lessonId}")
    public ResponseEntity<Boss> getBossByLesson(@PathVariable String lessonId) {
        Lesson lesson = lessonRepository.findById(lessonId)
            .orElseThrow(() -> new RuntimeException("Lesson not found"));
        
        return bossRepository.findByLesson(lesson)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/quizzes/boss/{bossId}")
    public ResponseEntity<List<Quiz>> getQuizzesByBoss(@PathVariable String bossId) {
        Boss boss = bossRepository.findById(bossId)
            .orElseThrow(() -> new RuntimeException("Boss not found"));
        
        Lesson lesson = boss.getLesson();
        List<Quiz> quizzes = quizRepository.findByLessonOrderByCreatedAtAsc(lesson);
        
        return ResponseEntity.ok(quizzes);
    }
    
    @PostMapping("/quiz/generate/{lessonId}")
    public ResponseEntity<Map<String, Object>> generateQuiz(@PathVariable String lessonId) {
        Map<String, Object> quiz = gameService.generateQuizForLesson(lessonId);
        return ResponseEntity.ok(quiz);
    }
    
    @PostMapping("/quiz/submit")
    public ResponseEntity<Map<String, Object>> submitAnswer(
        @RequestBody Map<String, String> request
    ) {
        String studentId = request.get("studentId");
        String quizId = request.get("quizId");
        String answer = request.get("answer");
        
        Map<String, Object> result = gameService.submitAnswer(studentId, quizId, answer);
        return ResponseEntity.ok(result);
    }
    
    @GetMapping("/quizzes/lesson/{lessonId}")
    public ResponseEntity<List<Quiz>> getQuizzesByLesson(@PathVariable String lessonId) {
        List<Quiz> quizzes = gameService.getQuizzesByLesson(lessonId);
        return ResponseEntity.ok(quizzes);
    }
}
