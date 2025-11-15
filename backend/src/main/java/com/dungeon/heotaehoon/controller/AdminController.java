package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import com.dungeon.heotaehoon.service.StudentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final StudentRepository studentRepository;
    private final LessonRepository lessonRepository;
    private final StudentService studentService;

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
