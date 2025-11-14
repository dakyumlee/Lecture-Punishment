package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {
    
    private final LessonRepository lessonRepository;
    private final InstructorRepository instructorRepository;
    private final StudentRepository studentRepository;
    private final BossRepository bossRepository;
    
    @PostMapping("/lessons")
    public ResponseEntity<Lesson> createLesson(@RequestBody Map<String, Object> lessonData) {
        Instructor instructor = instructorRepository.findByName("허태훈")
            .orElseThrow(() -> new RuntimeException("Instructor not found"));
        
        Lesson lesson = new Lesson();
        lesson.setInstructor(instructor);
        lesson.setTitle((String) lessonData.get("title"));
        lesson.setSubject((String) lessonData.get("subject"));
        lesson.setDifficultyStars((Integer) lessonData.get("difficultyStars"));
        lesson.setLessonDate(LocalDate.parse((String) lessonData.get("lessonDate")));
        lesson.setIsActive(true);
        lesson.setCreatedAt(LocalDateTime.now());
        
        Lesson savedLesson = lessonRepository.save(lesson);
        
        Boss boss = new Boss();
        boss.setLesson(savedLesson);
        boss.setName(savedLesson.getSubject() + " 보스");
        boss.setHpTotal(1000 * savedLesson.getDifficultyStars());
        boss.setHpCurrent(1000 * savedLesson.getDifficultyStars());
        boss.setIsDefeated(false);
        boss.setCreatedAt(LocalDateTime.now());
        bossRepository.save(boss);
        
        return ResponseEntity.ok(savedLesson);
    }
    
    @GetMapping("/lessons")
    public ResponseEntity<List<Lesson>> getAllLessons() {
        List<Lesson> lessons = lessonRepository.findAll();
        return ResponseEntity.ok(lessons);
    }
    
    @DeleteMapping("/lessons/{id}")
    public ResponseEntity<Map<String, String>> deleteLesson(@PathVariable String id) {
        lessonRepository.deleteById(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "수업이 삭제되었습니다");
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/students")
    public ResponseEntity<List<Student>> getAllStudents() {
        List<Student> students = studentRepository.findAll();
        return ResponseEntity.ok(students);
    }
    
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStats() {
        Map<String, Object> stats = new HashMap<>();
        
        long totalStudents = studentRepository.count();
        long totalLessons = lessonRepository.count();
        
        List<Student> students = studentRepository.findAll();
        int totalCorrect = students.stream().mapToInt(Student::getTotalCorrect).sum();
        int totalWrong = students.stream().mapToInt(Student::getTotalWrong).sum();
        
        stats.put("totalStudents", totalStudents);
        stats.put("totalLessons", totalLessons);
        stats.put("totalCorrect", totalCorrect);
        stats.put("totalWrong", totalWrong);
        stats.put("averageLevel", students.stream().mapToInt(Student::getLevel).average().orElse(0));
        
        return ResponseEntity.ok(stats);
    }
}
