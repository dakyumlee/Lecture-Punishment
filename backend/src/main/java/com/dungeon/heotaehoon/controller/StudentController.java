package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.service.StudentService;
import com.dungeon.heotaehoon.service.InstructorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/students")
@RequiredArgsConstructor
public class StudentController {

    private final StudentService studentService;
    private final InstructorService instructorService;

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

    @PostMapping("/{studentId}/expression")
    public ResponseEntity<?> changeExpression(
            @PathVariable String studentId,
            @RequestBody Map<String, String> request) {
        Student student = studentService.changeExpression(
                studentId,
                request.get("expression")
        );
        return ResponseEntity.ok(Map.of(
            "success", true,
            "student", student,
            "message", "표정이 변경되었습니다"
        ));
    }

    @PostMapping("/{studentId}/exp")
    public ResponseEntity<Map<String, Object>> addExp(
            @PathVariable String studentId,
            @RequestBody Map<String, Integer> request) {
        Integer expAmount = request.get("exp");
        Map<String, Object> result = studentService.addExp(studentId, expAmount != null ? expAmount : 10);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/{studentId}/stats")
    public ResponseEntity<Map<String, Object>> updateStats(
            @PathVariable String studentId,
            @RequestBody Map<String, Boolean> request) {
        Boolean isCorrect = request.get("isCorrect");
        Student student = studentService.updateQuizStats(studentId, isCorrect != null && isCorrect);
        
        int pointsEarned = 0;
        Map<String, Object> mentalResult = null;
        
        if (isCorrect != null && isCorrect) {
            pointsEarned = 5;
            student.setPoints(student.getPoints() + pointsEarned);
            studentService.updateProfile(studentId, null, null, null, null);
            instructorService.addInstructorExp(1);
        } else {
            instructorService.addRage(5);
            mentalResult = studentService.reduceMental(studentId, 10);
            student = (Student) mentalResult.get("student");
        }
        
        Map<String, Object> result = Map.of(
            "student", student,
            "pointsEarned", pointsEarned,
            "mentalStatus", mentalResult != null ? mentalResult.get("mentalStatus") : "양호",
            "needsRecovery", mentalResult != null ? mentalResult.get("needsRecovery") : false
        );
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{studentId}/stats")
    public ResponseEntity<Map<String, Object>> getStudentStats(@PathVariable String studentId) {
        return ResponseEntity.ok(studentService.getStudentStats(studentId));
    }

    @GetMapping("/top")
    public ResponseEntity<?> getTopStudents() {
        return ResponseEntity.ok(studentService.getTopStudents());
    }

    @PostMapping("/{studentId}/mental")
    public ResponseEntity<Map<String, Object>> updateMental(
            @PathVariable String studentId,
            @RequestBody Map<String, Integer> request) {
        Integer amount = request.get("amount");
        
        if (amount > 0) {
            return ResponseEntity.ok(studentService.recoverMental(studentId, amount));
        } else {
            return ResponseEntity.ok(studentService.reduceMental(studentId, Math.abs(amount)));
        }
    }
}
