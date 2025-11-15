package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.StudentGroup;
import com.dungeon.heotaehoon.repository.StudentRepository;
import com.dungeon.heotaehoon.repository.StudentGroupRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class StudentService {
    private final StudentRepository studentRepository;
    private final StudentGroupRepository groupRepository;

    public Student getStudentById(String id) {
        return studentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
    }

    public Student getStudentByUsername(String username) {
        return studentRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
    }

    @Transactional
    public Student createStudent(String username, String displayName, String groupId) {
        Student student = new Student();
        student.setId(UUID.randomUUID().toString());
        student.setUsername(username);
        student.setDisplayName(displayName);
        student.setLevel(1);
        student.setExp(0);
        student.setPoints(0);
        student.setTotalCorrect(0);
        student.setTotalWrong(0);
        student.setIsProfileComplete(false);
        
        if (groupId != null && !groupId.isEmpty()) {
            StudentGroup group = groupRepository.findById(groupId)
                    .orElseThrow(() -> new RuntimeException("그룹을 찾을 수 없습니다"));
            student.setGroup(group);
        }
        
        return studentRepository.save(student);
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
        data.put("totalCorrect", 0);
        data.put("totalWrong", 0);
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

    @Transactional
    public Student changeExpression(String studentId, String expression) {
        Student student = getStudentById(studentId);
        student.setCharacterExpression(expression);
        return studentRepository.save(student);
    }

    public List<Student> getTopStudents() {
        return studentRepository.findTop10ByOrderByExpDesc();
    }

    public Map<String, Object> getStudentStats(String studentId) {
        Student student = getStudentById(studentId);
        Map<String, Object> stats = new HashMap<>();

        stats.put("level", student.getLevel());
        stats.put("exp", student.getExp());
        stats.put("totalCorrect", 0);
        stats.put("totalWrong", 0);
        stats.put("accuracy", 0.0);
        stats.put("mentalGauge", 100);
        stats.put("points", student.getPoints());

        return stats;
    }
}
