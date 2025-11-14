package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Instructor;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.InstructorRepository;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final StudentRepository studentRepository;
    private final InstructorRepository instructorRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public Student studentLogin(String name, String birthDate, String phoneNumber) {
        List<Student> students = studentRepository.findByDisplayName(name);
        
        if (students.isEmpty()) {
            Student newStudent = Student.builder()
                    .username(generateUsername(name))
                    .displayName(name)
                    .level(1)
                    .exp(0)
                    .mentalGauge(100)
                    .totalCorrect(0)
                    .totalWrong(0)
                    .characterExpression("normal")
                    .characterOutfit("default")
                    .points(0)
                    .isProfileComplete(false)
                    .build();
            return studentRepository.save(newStudent);
        }
        
        if (students.size() == 1) {
            return students.get(0);
        }
        
        if (birthDate != null || phoneNumber != null) {
            for (Student student : students) {
                boolean birthDateMatch = (birthDate == null || 
                    (student.getBirthDate() != null && student.getBirthDate().toString().replace("-", "").equals(birthDate.replace("-", ""))));
                boolean phoneMatch = (phoneNumber == null || 
                    (student.getPhoneNumber() != null && student.getPhoneNumber().equals(phoneNumber)));
                
                if (birthDateMatch && phoneMatch) {
                    return student;
                }
            }
        }
        
        throw new RuntimeException("동명이인이 있습니다. 생년월일 또는 휴대폰 번호를 입력해주세요.");
    }

    public Optional<Instructor> instructorLogin(String username, String password) {
        Optional<Instructor> instructor = instructorRepository.findByUsername(username);
        if (instructor.isPresent() && passwordEncoder.matches(password, instructor.get().getPassword())) {
            return instructor;
        }
        return Optional.empty();
    }

    private String generateUsername(String displayName) {
        String baseUsername = displayName.replaceAll("\\s+", "");
        String username = baseUsername;
        int counter = 1;
        
        while (studentRepository.findByUsername(username).isPresent()) {
            username = baseUsername + counter;
            counter++;
        }
        
        return username;
    }
}
