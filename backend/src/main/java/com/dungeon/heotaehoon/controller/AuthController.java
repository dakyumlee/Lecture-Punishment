package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Instructor;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.InstructorRepository;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private final StudentRepository studentRepository;
    private final InstructorRepository instructorRepository;

    @PostMapping("/student/login")
    public ResponseEntity<?> studentLogin(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        
        Student student = studentRepository.findByUsername(username)
                .orElseGet(() -> {
                    Student newStudent = Student.builder()
                            .username(username)
                            .displayName(username)
                            .createdAt(LocalDateTime.now())
                            .build();
                    return studentRepository.save(newStudent);
                });

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("student", student);
        response.put("needsProfile", !student.getIsProfileComplete());
        response.put("message", student.getIsProfileComplete() ? "로그인 성공" : "프로필 완성이 필요합니다");
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/instructor/login")
    public ResponseEntity<?> instructorLogin(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String password = request.get("password");

        Instructor instructor = instructorRepository.findByUsername(username)
                .orElse(null);

        if (instructor == null) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "존재하지 않는 계정입니다"
            ));
        }

        if (!instructor.getPassword().equals(password)) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "비밀번호가 일치하지 않습니다"
            ));
        }

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("instructor", instructor);
        response.put("message", "로그인 성공");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/instructor/register")
    public ResponseEntity<?> instructorRegister(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String password = request.get("password");
        String name = request.get("name");

        if (instructorRepository.findByUsername(username).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "이미 존재하는 아이디입니다"
            ));
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
}
