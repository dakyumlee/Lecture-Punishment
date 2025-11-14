package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Instructor;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.InstructorRepository;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final StudentRepository studentRepository;
    private final InstructorRepository instructorRepository;

    @PostMapping("/login")
    public ResponseEntity<?> studentLogin(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String birthDateStr = request.get("birthDate");
        String phoneNumber = request.get("phoneNumber");

        List<Student> studentsWithSameName = studentRepository.findAllByUsername(username);

        if (studentsWithSameName.isEmpty()) {
            Student newStudent = Student.builder()
                    .username(username)
                    .displayName(username)
                    .createdAt(LocalDateTime.now())
                    .build();
            Student saved = studentRepository.save(newStudent);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("student", saved);
            response.put("needsProfile", true);
            response.put("message", "프로필 완성이 필요합니다");
            return ResponseEntity.ok(response);
        }

        if (studentsWithSameName.size() == 1) {
            Student student = studentsWithSameName.get(0);
            
            if (!student.getIsProfileComplete()) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("student", student);
                response.put("needsProfile", true);
                response.put("message", "프로필 완성이 필요합니다");
                return ResponseEntity.ok(response);
            }

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("student", student);
            response.put("needsProfile", false);
            response.put("message", "로그인 성공");
            return ResponseEntity.ok(response);
        }

        if (birthDateStr == null && phoneNumber == null) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "동명이인");
            response.put("hasDuplicates", true);
            return ResponseEntity.badRequest().body(response);
        }

        Student foundStudent = null;

        if (birthDateStr != null && !birthDateStr.isEmpty()) {
            try {
                LocalDate birthDate = LocalDate.parse(birthDateStr, DateTimeFormatter.ofPattern("yyyyMMdd"));
                foundStudent = studentRepository.findByUsernameAndBirthDate(username, birthDate).orElse(null);
            } catch (Exception e) {
                // 날짜 파싱 실패
            }
        }

        if (foundStudent == null && phoneNumber != null && !phoneNumber.isEmpty()) {
            foundStudent = studentRepository.findByUsernameAndPhoneNumber(username, phoneNumber).orElse(null);
        }

        if (foundStudent == null) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "일치하는 학생 정보를 찾을 수 없습니다");
            return ResponseEntity.badRequest().body(response);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("student", foundStudent);
        response.put("needsProfile", !foundStudent.getIsProfileComplete());
        response.put("message", "로그인 성공");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/admin/login")
    public ResponseEntity<?> adminLogin(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String password = request.get("password");

        Instructor instructor = instructorRepository.findByUsername(username)
                .orElse(null);

        if (instructor == null) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "존재하지 않는 계정입니다");
            return ResponseEntity.badRequest().body(response);
        }

        if (!instructor.getPassword().equals(password)) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "비밀번호가 일치하지 않습니다");
            return ResponseEntity.badRequest().body(response);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("instructor", instructor);
        response.put("message", "로그인 성공");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/admin/register")
    public ResponseEntity<?> adminRegister(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String password = request.get("password");
        String name = request.get("name");

        if (instructorRepository.findByUsername(username).isPresent()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "이미 존재하는 아이디입니다");
            return ResponseEntity.badRequest().body(response);
        }

        Instructor instructor = Instructor.builder()
                .username(username)
                .password(password)
                .name(name)
                .createdAt(LocalDateTime.now())
                .build();

        instructorRepository.save(instructor);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("instructor", instructor);
        response.put("message", "회원가입 성공");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/profile/complete")
    public ResponseEntity<?> completeProfile(@RequestBody Map<String, String> request) {
        String studentId = request.get("studentId");
        String birthDateStr = request.get("birthDate");
        String phoneNumber = request.get("phoneNumber");

        Student student = studentRepository.findById(studentId).orElse(null);
        if (student == null) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "학생을 찾을 수 없습니다"));
        }

        if (birthDateStr != null && !birthDateStr.isEmpty()) {
            try {
                LocalDate birthDate = LocalDate.parse(birthDateStr);
                student.setBirthDate(birthDate);
            } catch (Exception e) {
                // 파싱 실패 무시
            }
        }

        if (phoneNumber != null && !phoneNumber.isEmpty()) {
            student.setPhoneNumber(phoneNumber);
        }

        student.setIsProfileComplete(true);
        studentRepository.save(student);

        return ResponseEntity.ok(Map.of("success", true, "student", student, "message", "프로필 완성"));
    }
}
