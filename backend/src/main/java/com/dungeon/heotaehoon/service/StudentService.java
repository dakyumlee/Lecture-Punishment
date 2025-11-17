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

    @Transactional
    public Student changeExpression(String studentId, String expression) {
        Student student = getStudentById(studentId);
        student.setCharacterExpression(expression);
        return studentRepository.save(student);
    }

    @Transactional
    public Map<String, Object> addExp(String studentId, int expAmount) {
        Student student = getStudentById(studentId);
        
        int oldLevel = student.getLevel();
        int oldExp = student.getExp();
        
        student.setExp(oldExp + expAmount);
        
        int newLevel = oldLevel;
        boolean leveledUp = false;
        
        while (student.getExp() >= 100) {
            student.setExp(student.getExp() - 100);
            newLevel++;
            leveledUp = true;
        }
        
        if (leveledUp) {
            student.setLevel(newLevel);
        }
        
        studentRepository.save(student);
        
        Map<String, Object> result = new HashMap<>();
        result.put("student", student);
        result.put("leveledUp", leveledUp);
        result.put("oldLevel", oldLevel);
        result.put("newLevel", newLevel);
        result.put("expGained", expAmount);
        
        return result;
    }

    @Transactional
    public Student updateQuizStats(String studentId, boolean isCorrect) {
        Student student = getStudentById(studentId);
        
        if (isCorrect) {
            student.setTotalCorrect(student.getTotalCorrect() + 1);
        } else {
            student.setTotalWrong(student.getTotalWrong() + 1);
        }
        
        return studentRepository.save(student);
    }

    public List<Student> getTopStudents() {
        return studentRepository.findTop10ByOrderByExpDesc();
    }

    public Map<String, Object> getStudentStats(String studentId) {
        Student student = getStudentById(studentId);
        Map<String, Object> stats = new HashMap<>();

        int totalQuizzes = student.getTotalCorrect() + student.getTotalWrong();
        double accuracy = totalQuizzes > 0 
            ? (student.getTotalCorrect() * 100.0 / totalQuizzes) 
            : 0.0;

        stats.put("level", student.getLevel());
        stats.put("exp", student.getExp());
        stats.put("totalCorrect", student.getTotalCorrect());
        stats.put("totalWrong", student.getTotalWrong());
        stats.put("accuracy", Math.round(accuracy * 10.0) / 10.0);
        stats.put("mentalGauge", 100);
        stats.put("points", student.getPoints());

        return stats;
    }
}

    @Transactional
    public Student updateMentalGauge(String studentId, int amount) {
        Student student = getStudentById(studentId);
        
        int newMental = Math.max(0, Math.min(100, student.getMentalGauge() + amount));
        student.setMentalGauge(newMental);
        
        return studentRepository.save(student);
    }

    @Transactional
    public Map<String, Object> reduceMental(String studentId, int amount) {
        Student student = getStudentById(studentId);
        
        int oldMental = student.getMentalGauge();
        int newMental = Math.max(0, oldMental - amount);
        student.setMentalGauge(newMental);
        
        boolean needsRecovery = newMental < 30;
        String mentalStatus = getMentalStatus(newMental);
        
        studentRepository.save(student);
        
        Map<String, Object> result = new HashMap<>();
        result.put("student", student);
        result.put("oldMental", oldMental);
        result.put("newMental", newMental);
        result.put("needsRecovery", needsRecovery);
        result.put("mentalStatus", mentalStatus);
        
        return result;
    }

    @Transactional
    public Map<String, Object> recoverMental(String studentId, int amount) {
        Student student = getStudentById(studentId);
        
        int oldMental = student.getMentalGauge();
        int newMental = Math.min(100, oldMental + amount);
        student.setMentalGauge(newMental);
        
        String mentalStatus = getMentalStatus(newMental);
        
        studentRepository.save(student);
        
        Map<String, Object> result = new HashMap<>();
        result.put("student", student);
        result.put("oldMental", oldMental);
        result.put("newMental", newMental);
        result.put("recovered", amount);
        result.put("mentalStatus", mentalStatus);
        
        return result;
    }

    private String getMentalStatus(int mentalGauge) {
        if (mentalGauge >= 80) {
            return "최상";
        } else if (mentalGauge >= 60) {
            return "양호";
        } else if (mentalGauge >= 40) {
            return "보통";
        } else if (mentalGauge >= 30) {
            return "주의";
        } else {
            return "위험 - 회복 필요!";
        }
    }
}
