package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import com.dungeon.heotaehoon.service.StudentService;
import com.dungeon.heotaehoon.service.AiQuizGenerationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final StudentRepository studentRepository;
    private final LessonRepository lessonRepository;
    private final InstructorRepository instructorRepository;
    private final StudentGroupRepository studentGroupRepository;
    private final BossRepository bossRepository;
    private final StudentService studentService;
    private final AiQuizGenerationService aiQuizGenerationService;

    @GetMapping("/students")
    public ResponseEntity<List<Student>> getAllStudents() {
        List<Student> students = studentRepository.findAll();
        return ResponseEntity.ok(students);
    }
    
    @PostMapping("/students")
    public ResponseEntity<Student> createStudent(@RequestBody Map<String, Object> request) {
        String username = (String) request.get("username");
        String displayName = (String) request.get("displayName");
        String groupId = (String) request.get("groupId");
        
        Student student = studentService.createStudent(username, displayName, groupId);
        return ResponseEntity.ok(student);
    }

    @DeleteMapping("/students/{id}")
    public ResponseEntity<Void> deleteStudent(@PathVariable String id) {
        studentRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/lessons")
    public ResponseEntity<List<Lesson>> getAllLessons() {
        return ResponseEntity.ok(lessonRepository.findAll());
    }

    @PostMapping("/lessons")
    public ResponseEntity<Map<String, Object>> createLesson(@RequestBody Map<String, Object> request) {
        try {
            String title = (String) request.get("title");
            String description = (String) request.get("description");
            String subject = (String) request.get("subject");
            String groupId = (String) request.get("groupId");
            
            Instructor defaultInstructor = instructorRepository.findAll().stream().findFirst().orElse(null);
            
            StudentGroup group = null;
            if (groupId != null && !groupId.isEmpty()) {
                group = studentGroupRepository.findById(groupId).orElse(null);
            }
            
            Lesson lesson = Lesson.builder()
                    .title(title)
                    .subject(subject != null ? subject : description)
                    .instructor(defaultInstructor)
                    .group(group)
                    .lessonDate(LocalDate.now())
                    .difficultyStars(3)
                    .isActive(true)
                    .createdAt(LocalDateTime.now())
                    .build();
            
            Lesson savedLesson = lessonRepository.save(lesson);
            log.info("Created lesson: {}", savedLesson.getId());
            
            Boss boss = Boss.builder()
                    .lesson(savedLesson)
                    .bossName("오늘의 보스: " + (subject != null ? subject : title))
                    .bossSubtitle("지식의 수호자")
                    .totalHp(1000)
                    .currentHp(1000)
                    .isDefeated(false)
                    .defeatRewardExp(100)
                    .createdAt(LocalDateTime.now())
                    .build();
            
            Boss savedBoss = bossRepository.save(boss);
            log.info("Created boss: {} for lesson: {}", savedBoss.getId(), savedLesson.getId());
            
            try {
                aiQuizGenerationService.generateQuizzesForBoss(
                    savedBoss, 
                    subject != null ? subject : title, 
                    5
                );
                log.info("AI quizzes generated for boss: {}", savedBoss.getId());
            } catch (Exception e) {
                log.warn("Failed to generate AI quizzes: {}", e.getMessage());
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("lessonId", savedLesson.getId());
            response.put("bossId", savedBoss.getId());
            response.put("message", "수업과 보스가 생성되었습니다");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to create lesson", e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    @DeleteMapping("/lessons/{id}")
    public ResponseEntity<Void> deleteLesson(@PathVariable String id) {
        lessonRepository.deleteById(id);
        return ResponseEntity.ok().build();
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
