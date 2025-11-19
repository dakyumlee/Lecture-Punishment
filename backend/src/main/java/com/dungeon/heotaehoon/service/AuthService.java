package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Instructor;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.InstructorRepository;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final StudentRepository studentRepository;
    private final InstructorRepository instructorRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public Student studentSignup(String displayName, LocalDate birthDate, String password) {
        String studentId = generateStudentId();
        
        Student newStudent = Student.builder()
                .username(studentId)
                .displayName(displayName)
                .birthDate(birthDate)
                .password(passwordEncoder.encode(password))
                .level(1)
                .exp(0)
                .mentalGauge(100)
                .totalCorrect(0)
                .totalWrong(0)
                .characterExpression("😊")
                .characterOutfit("default")
                .points(0)
                .isProfileComplete(true)
                .build();
        
        return studentRepository.save(newStudent);
    }

    @Transactional
    public Optional<Student> studentLogin(String studentId, String password) {
        Optional<Student> studentOpt = studentRepository.findByUsername(studentId);
        
        if (studentOpt.isEmpty()) {
            return Optional.empty();
        }
        
        Student student = studentOpt.get();
        
        if (password == null || !passwordEncoder.matches(password, student.getPassword())) {
            return Optional.empty();
        }
        
        return Optional.of(student);
    }

    public Optional<Instructor> instructorLogin(String username, String password) {
        Optional<Instructor> instructor = instructorRepository.findByUsername(username);
        if (instructor.isPresent() && passwordEncoder.matches(password, instructor.get().getPassword())) {
            return instructor;
        }
        return Optional.empty();
    }

    private String generateStudentId() {
        String prefix = "DGK";
        int counter = 1;
        
        List<Student> allStudents = studentRepository.findAll();
        
        for (Student student : allStudents) {
            String username = student.getUsername();
            if (username != null && username.startsWith(prefix)) {
                try {
                    String numberPart = username.substring(prefix.length());
                    int number = Integer.parseInt(numberPart);
                    if (number >= counter) {
                        counter = number + 1;
                    }
                } catch (NumberFormatException e) {
                }
            }
        }
        
        return String.format("%s%03d", prefix, counter);
    }
}
