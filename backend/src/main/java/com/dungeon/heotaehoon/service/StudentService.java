package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class StudentService {
    private final StudentRepository studentRepository;

    public Student getStudentById(String id) {
        return studentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
    }

    public Student getStudentByUsername(String username) {
        return studentRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
    }

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

    public Map<String, Object> getMyPageData(String studentId) {
        Student student = getStudentById(studentId);
        Map<String, Object> data = new HashMap<>();
        data.put("student", student);
        data.put("level", student.getLevel());
        data.put("exp", student.getExp());
        data.put("points", student.getPoints());
        data.put("totalCorrect", student.getTotalCorrect());
        data.put("totalWrong", student.getTotalWrong());
        return data;
    }

    @Transactional
    public Student updateProfile(String studentId, String displayName, String birthDate, String phoneNumber, String studentIdNumber) {
        Student student = getStudentById(studentId);

        if (displayName != null && !displayName.isEmpty()) {
            student.setDisplayName(displayName);
        }

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

        return studentRepository.save(student);
    }

    public Map<String, Object> getStudentStats(String studentId) {
        Student student = getStudentById(studentId);
        Map<String, Object> stats = new HashMap<>();
        
        int totalAttempts = student.getTotalCorrect() + student.getTotalWrong();
        double accuracy = totalAttempts > 0 ? (double) student.getTotalCorrect() / totalAttempts * 100 : 0;

        stats.put("level", student.getLevel());
        stats.put("exp", student.getExp());
        stats.put("totalCorrect", student.getTotalCorrect());
        stats.put("totalWrong", student.getTotalWrong());
        stats.put("accuracy", Math.round(accuracy * 10) / 10.0);
        stats.put("mentalGauge", student.getMentalGauge());
        stats.put("points", student.getPoints());

        return stats;
    }
}
