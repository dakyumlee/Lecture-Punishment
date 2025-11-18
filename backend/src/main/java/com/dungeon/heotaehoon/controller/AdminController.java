package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
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

    private final LessonRepository lessonRepository;
    private final BossRepository bossRepository;
    private final StudentRepository studentRepository;
    private final InstructorRepository instructorRepository;
    private final QuizRepository quizRepository;
    private final StudentGroupRepository studentGroupRepository;
    private final AiQuizGenerationService aiQuizGenerationService;

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getAdminStats() {
        Map<String, Object> stats = new HashMap<>();
        
        long totalStudents = studentRepository.count();
        long totalLessons = lessonRepository.count();
        long totalQuizzes = quizRepository.count();
        
        List<Student> allStudents = studentRepository.findAll();
        int totalCorrect = allStudents.stream().mapToInt(Student::getTotalCorrect).sum();
        int totalWrong = allStudents.stream().mapToInt(Student::getTotalWrong).sum();
        int totalAttempts = totalCorrect + totalWrong;
        String successRate = totalAttempts > 0 
            ? String.format("%.1f%%", (totalCorrect * 100.0 / totalAttempts))
            : "0%";
        
        stats.put("totalStudents", totalStudents);
        stats.put("totalLessons", totalLessons);
        stats.put("totalQuizzes", totalQuizzes);
        stats.put("successRate", successRate);
        
        return ResponseEntity.ok(stats);
    }

    @PostMapping("/lessons")
    public ResponseEntity<Map<String, Object>> createLesson(@RequestBody Map<String, Object> request) {
        try {
            String title = (String) request.get("title");
            String description = (String) request.get("description");
            String subject = (String) request.get("subject");
            String groupId = (String) request.get("groupId");
            Integer difficulty = request.get("difficulty") != null 
                ? ((Number) request.get("difficulty")).intValue() 
                : 3;
            
            if (difficulty < 1 || difficulty > 5) {
                difficulty = 3;
            }
            
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
                    .difficultyStars(difficulty)
                    .isActive(true)
                    .createdAt(LocalDateTime.now())
                    .build();
            
            Lesson savedLesson = lessonRepository.save(lesson);
            log.info("Created lesson: {} with difficulty: {}", savedLesson.getId(), difficulty);
            
            String bossName = getBossNameByDifficulty(difficulty, subject != null ? subject : title);
            String specialAbility = getSpecialAbilityByDifficulty(difficulty);
            
            Boss boss = Boss.builder()
                    .lesson(savedLesson)
                    .bossName(bossName)
                    .bossSubtitle(getSubtitleByDifficulty(difficulty))
                    .difficulty(difficulty)
                    .specialAbility(specialAbility)
                    .isDefeated(false)
                    .createdAt(LocalDateTime.now())
                    .build();
            
            Boss savedBoss = bossRepository.save(boss);
            log.info("Created boss: {} for lesson: {} with difficulty: {} stars", 
                savedBoss.getId(), savedLesson.getId(), difficulty);
            
            int quizCount = getQuizCountByDifficulty(difficulty);
            
            try {
                aiQuizGenerationService.generateQuizzesForBoss(
                    savedBoss.getId(), 
                    subject != null ? subject : title, 
                    quizCount
                );
                log.info("AI quizzes generated for boss: {} (count: {})", savedBoss.getId(), quizCount);
            } catch (Exception e) {
                log.warn("Failed to generate AI quizzes: {}", e.getMessage());
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("lesson", savedLesson);
            response.put("boss", savedBoss);
            response.put("message", "수업과 보스가 생성되었습니다");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to create lesson", e);
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    private String getBossNameByDifficulty(int difficulty, String subject) {
        switch (difficulty) {
            case 1: return "입문 보스: " + subject;
            case 2: return "초급 보스: " + subject;
            case 3: return "중급 보스: " + subject;
            case 4: return "상급 보스: " + subject;
            case 5: return "허태훈의 진노: " + subject;
            default: return "보스: " + subject;
        }
    }

    private String getSubtitleByDifficulty(int difficulty) {
        switch (difficulty) {
            case 1: return "기초의 수호자";
            case 2: return "지식의 문지기";
            case 3: return "지식의 수호자";
            case 4: return "지식의 파수꾼";
            case 5: return "최종 관문";
            default: return "지식의 수호자";
        }
    }

    private String getSpecialAbilityByDifficulty(int difficulty) {
        switch (difficulty) {
            case 1: return "없음";
            case 2: return "압박: 틀리면 다음 문제 시간 -10초";
            case 3: return "분노 폭발: 3문제 연속 틀리면 HP 10% 회복";
            case 4: return "광폭화: HP 50% 이하 시 데미지 2배 필요";
            case 5: return "허태훈의 진노: 모든 패널티 + HP 30% 회복";
            default: return "없음";
        }
    }

    private int getQuizCountByDifficulty(int difficulty) {
        switch (difficulty) {
            case 1: return 10;
            case 2: return 15;
            case 3: return 20;
            case 4: return 25;
            case 5: return 30;
            default: return 15;
        }
    }

    @GetMapping("/lessons")
    public ResponseEntity<List<Map<String, Object>>> getAdminLessons() {
        List<Lesson> lessons = lessonRepository.findAll();
        List<Map<String, Object>> result = new ArrayList<>();
        
        for (Lesson lesson : lessons) {
            Map<String, Object> lessonData = new HashMap<>();
            lessonData.put("id", lesson.getId());
            lessonData.put("title", lesson.getTitle());
            lessonData.put("subject", lesson.getSubject());
            lessonData.put("difficulty", lesson.getDifficultyStars());
            lessonData.put("lessonDate", lesson.getLessonDate().toString());
            lessonData.put("isActive", lesson.getIsActive());
            
            result.add(lessonData);
        }
        
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/lessons/{id}")
    public ResponseEntity<Map<String, Object>> deleteLesson(@PathVariable String id) {
        try {
            log.info("Deleting lesson: {}", id);
            lessonRepository.deleteById(id);
            return ResponseEntity.ok(Map.of("success", true, "message", "수업이 삭제되었습니다"));
        } catch (Exception e) {
            log.error("Failed to delete lesson: {}", id, e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @GetMapping("/students")
    public ResponseEntity<List<Map<String, Object>>> getAdminStudents() {
        List<Student> students = studentRepository.findAll();
        List<Map<String, Object>> result = new ArrayList<>();
        
        for (Student student : students) {
            Map<String, Object> studentData = new HashMap<>();
            studentData.put("id", student.getId());
            studentData.put("username", student.getUsername());
            studentData.put("displayName", student.getDisplayName());
            studentData.put("level", student.getLevel());
            studentData.put("exp", student.getExp());
            studentData.put("points", student.getPoints());
            
            result.add(studentData);
        }
        
        return ResponseEntity.ok(result);
    }

    @PostMapping("/students")
    public ResponseEntity<Map<String, Object>> createStudent(@RequestBody Map<String, String> request) {
        try {
            String username = request.get("username");
            String displayName = request.get("displayName");
            String groupId = request.get("groupId");
            
            if (studentRepository.findByUsername(username).isPresent()) {
                return ResponseEntity.badRequest().body(Map.of("error", "이미 존재하는 사용자명입니다"));
            }
            
            StudentGroup group = null;
            if (groupId != null && !groupId.isEmpty()) {
                group = studentGroupRepository.findById(groupId).orElse(null);
            }
            
            Student student = Student.builder()
                    .username(username)
                    .displayName(displayName)
                    .group(group)
                    .level(1)
                    .exp(0)
                    .points(0)
                    .totalCorrect(0)
                    .totalWrong(0)
                    .mentalGauge(100)
                    .isProfileComplete(false)
                    .createdAt(LocalDateTime.now())
                    .build();
            
            Student savedStudent = studentRepository.save(student);
            
            Map<String, Object> response = new HashMap<>();
            response.put("id", savedStudent.getId());
            response.put("username", savedStudent.getUsername());
            response.put("displayName", savedStudent.getDisplayName());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to create student", e);
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @DeleteMapping("/students/{id}")
    public ResponseEntity<Map<String, Object>> deleteStudent(@PathVariable String id) {
        try {
            studentRepository.deleteById(id);
            return ResponseEntity.ok(Map.of("success", true, "message", "학생이 삭제되었습니다"));
        } catch (Exception e) {
            log.error("Failed to delete student: {}", id, e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }
}
