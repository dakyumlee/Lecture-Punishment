package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.service.StudentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/students")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class StudentController {

    private final StudentService studentService;

    @GetMapping("/{studentId}")
    public ResponseEntity<Student> getStudent(@PathVariable String studentId) {
        return ResponseEntity.ok(studentService.getStudentById(studentId));
    }

    @GetMapping("/username/{username}")
    public ResponseEntity<Student> getStudentByUsername(@PathVariable String username) {
        return ResponseEntity.ok(studentService.getStudentByUsername(username));
    }

    @PostMapping("/{studentId}/profile")
    public ResponseEntity<Student> completeProfile(
            @PathVariable String studentId,
            @RequestBody Map<String, String> profileData) {
        Student student = studentService.completeProfile(
                studentId,
                profileData.get("birthDate"),
                profileData.get("phoneNumber"),
                profileData.get("studentIdNumber")
        );
        return ResponseEntity.ok(student);
    }

    @GetMapping("/{studentId}/mypage")
    public ResponseEntity<Map<String, Object>> getMyPage(@PathVariable String studentId) {
        return ResponseEntity.ok(studentService.getMyPageData(studentId));
    }

    @PutMapping("/{studentId}/profile")
    public ResponseEntity<Student> updateProfile(
            @PathVariable String studentId,
            @RequestBody Map<String, String> profileData) {
        Student student = studentService.updateProfile(
                studentId,
                profileData.get("displayName"),
                profileData.get("birthDate"),
                profileData.get("phoneNumber"),
                profileData.get("studentIdNumber")
        );
        return ResponseEntity.ok(student);
    }

    @GetMapping("/{studentId}/stats")
    public ResponseEntity<Map<String, Object>> getStudentStats(@PathVariable String studentId) {
        return ResponseEntity.ok(studentService.getStudentStats(studentId));
    }
}
