package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.StudentSubmission;
import com.dungeon.heotaehoon.entity.SubmissionAnswer;
import com.dungeon.heotaehoon.repository.StudentRepository;
import com.dungeon.heotaehoon.repository.StudentSubmissionRepository;
import com.dungeon.heotaehoon.repository.SubmissionAnswerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class StudentService {

    private final StudentRepository studentRepository;
    private final StudentSubmissionRepository submissionRepository;
    private final SubmissionAnswerRepository answerRepository;

    public Student getStudentById(String studentId) {
        return studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
    }

    public Student getStudentByUsername(String username) {
        return studentRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
    }

    @Transactional
    public Student completeProfile(String studentId, String birthDate, String phoneNumber, String studentIdNumber) {
        Student student = getStudentById(studentId);

        if (birthDate != null && !birthDate.isEmpty()) {
            student.setBirthDate(LocalDate.parse(birthDate, DateTimeFormatter.ISO_DATE));
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

    @Transactional
    public Student updateProfile(String studentId, String displayName, String birthDate, String phoneNumber, String studentIdNumber) {
        Student student = getStudentById(studentId);

        if (displayName != null && !displayName.isEmpty()) {
            student.setDisplayName(displayName);
        }
        if (birthDate != null && !birthDate.isEmpty()) {
            student.setBirthDate(LocalDate.parse(birthDate, DateTimeFormatter.ISO_DATE));
        }
        if (phoneNumber != null && !phoneNumber.isEmpty()) {
            student.setPhoneNumber(phoneNumber);
        }
        if (studentIdNumber != null && !studentIdNumber.isEmpty()) {
            student.setStudentIdNumber(studentIdNumber);
        }

        return studentRepository.save(student);
    }

    public Map<String, Object> getMyPageData(String studentId) {
        Student student = getStudentById(studentId);
        Map<String, Object> stats = getStudentStats(studentId);

        Map<String, Object> result = new HashMap<>();
        result.put("student", student);
        result.put("stats", stats);

        return result;
    }

    public Map<String, Object> getStudentStats(String studentId) {
        Student student = getStudentById(studentId);
        List<StudentSubmission> submissions = submissionRepository.findByStudent(student);

        int totalSubmissions = submissions.size();
        int totalScore = submissions.stream().mapToInt(StudentSubmission::getTotalScore).sum();
        double averageScore = totalSubmissions > 0 ? (double) totalScore / totalSubmissions : 0.0;

        int totalQuestions = 0;
        int correctAnswers = student.getTotalCorrect();
        int wrongAnswers = student.getTotalWrong();

        for (StudentSubmission submission : submissions) {
            List<SubmissionAnswer> answers = answerRepository.findBySubmission(submission);
            totalQuestions += answers.size();
        }

        double accuracyRate = totalQuestions > 0 ? (correctAnswers * 100.0) / totalQuestions : 0.0;

        Map<String, Object> stats = new HashMap<>();
        stats.put("level", student.getLevel());
        stats.put("exp", student.getExp());
        stats.put("points", student.getPoints());
        stats.put("mentalGauge", student.getMentalGauge());
        stats.put("totalSubmissions", totalSubmissions);
        stats.put("totalScore", totalScore);
        stats.put("averageScore", Math.round(averageScore * 10) / 10.0);
        stats.put("totalQuestions", totalQuestions);
        stats.put("correctAnswers", correctAnswers);
        stats.put("wrongAnswers", wrongAnswers);
        stats.put("accuracyRate", Math.round(accuracyRate * 10) / 10.0);
        stats.put("characterExpression", student.getCharacterExpression());
        stats.put("characterOutfit", student.getCharacterOutfit());

        return stats;
    }
}
