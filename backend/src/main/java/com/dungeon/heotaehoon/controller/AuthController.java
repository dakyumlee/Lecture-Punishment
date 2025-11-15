package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Instructor;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.InstructorRepository;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final StudentRepository studentRepository;
    private final InstructorRepository instructorRepository;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/login")
    public ResponseEntity<?> studentLogin(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String password = request.get("password");

        Optional<Student> studentOpt = studentRepository.findByUsername(username);

        if (studentOpt.isEmpty()) {
            Student newStudent = Student.builder()
                    .username(username)
                    .displayName(username)
                    .createdAt(LocalDateTime.now())
                    .isProfileComplete(false)
                    .build();
            Student saved = studentRepository.save(newStudent);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("student", saved);
            response.put("needsPassword", true);
            response.put("message", "비밀번호를 설정해주세요");
            return ResponseEntity.ok(response);
        }

        Student student = studentOpt.get();

        if (student.getPassword() == null || student.getPassword().isEmpty()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("student", student);
            response.put("needsPassword", true);
            response.put("message", "비밀번호를 설정해주세요");
            return ResponseEntity.ok(response);
        }

        if (password == null || password.isEmpty()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "비밀번호를 입력해주세요");
            return ResponseEntity.badRequest().body(response);
        }

        if (!passwordEncoder.matches(password, student.getPassword())) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "비밀번호가 일치하지 않습니다");
            return ResponseEntity.badRequest().body(response);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("student", student);
        response.put("needsPassword", false);
        response.put("needsProfile", !student.getIsProfileComplete());
        response.put("message", "로그인 성공");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/set-password")
    public ResponseEntity<?> setPassword(@RequestBody Map<String, String> request) {
        String studentId = request.get("studentId");
        String password = request.get("password");

        Student student = studentRepository.findById(studentId).orElse(null);
        if (student == null) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "학생을 찾을 수 없습니다"));
        }

        student.setPassword(passwordEncoder.encode(password));
        student.setIsProfileComplete(true);
        studentRepository.save(student);

        return ResponseEntity.ok(Map.of("success", true, "student", student, "message", "비밀번호 설정 완료"));
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

        if (!passwordEncoder.matches(password, instructor.getPassword())) {
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
                .password(passwordEncoder.encode(password))
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
}
