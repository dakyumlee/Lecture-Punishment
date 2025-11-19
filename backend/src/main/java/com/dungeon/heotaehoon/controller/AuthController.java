package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Instructor;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.InstructorRepository;
import com.dungeon.heotaehoon.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final InstructorRepository instructorRepository;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/signup")
    public ResponseEntity<?> studentSignup(@RequestBody Map<String, String> request) {
        String displayName = request.get("displayName");
        String birthDateStr = request.get("birthDate");
        String password = request.get("password");

        if (displayName == null || displayName.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "이름을 입력해주세요"
            ));
        }

        if (birthDateStr == null || birthDateStr.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "생년월일을 입력해주세요"
            ));
        }

        if (password == null || password.length() < 4) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "비밀번호는 최소 4자 이상이어야 합니다"
            ));
        }

        try {
            LocalDate birthDate = LocalDate.parse(birthDateStr);
            Student student = authService.studentSignup(displayName, birthDate, password);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("studentId", student.getUsername());
            response.put("displayName", student.getDisplayName());
            response.put("message", "회원가입 성공! 학생ID: " + student.getUsername());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "회원가입 실패: " + e.getMessage()
            ));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> studentLogin(@RequestBody Map<String, String> request) {
        String studentId = request.get("studentId");
        String password = request.get("password");

        if (studentId == null || studentId.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "학생ID를 입력해주세요"
            ));
        }

        if (password == null || password.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "비밀번호를 입력해주세요"
            ));
        }

        Optional<Student> studentOpt = authService.studentLogin(studentId, password);

        if (studentOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "학생ID 또는 비밀번호가 일치하지 않습니다"
            ));
        }

        Student student = studentOpt.get();

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("student", student);
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
