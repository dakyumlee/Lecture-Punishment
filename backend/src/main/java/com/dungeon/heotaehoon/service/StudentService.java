package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Service
@RequiredArgsConstructor
public class StudentService {
    private final StudentRepository studentRepository;

    @Transactional
    public Student completeProfile(String studentId, String birthDate, String phoneNumber, String studentIdNumber) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

        if (birthDate != null && !birthDate.isEmpty()) {
            LocalDate parsedDate;
            if (birthDate.contains("-")) {
                parsedDate = LocalDate.parse(birthDate);
            } else {
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
                parsedDate = LocalDate.parse(birthDate, formatter);
            }
            student.setBirthDate(parsedDate);
        }

        if (phoneNumber != null && !phoneNumber.isEmpty()) {
            student.setPhoneNumber(phoneNumber);
        }

        if (studentIdNumber != null && !studentIdNumber.isEmpty()) {
            student.setStudentIdNumber(studentIdNumber);
        }

        student.setIsProfileComplete(true);
        return studentRepository.save(student);
    }
}
