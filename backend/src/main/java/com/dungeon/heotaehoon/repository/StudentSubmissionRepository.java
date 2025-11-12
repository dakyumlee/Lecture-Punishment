package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.StudentSubmission;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.PdfWorksheet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentSubmissionRepository extends JpaRepository<StudentSubmission, String> {
    List<StudentSubmission> findByStudent(Student student);
    List<StudentSubmission> findByWorksheet(PdfWorksheet worksheet);
    List<StudentSubmission> findByStudentOrderBySubmissionDateDesc(Student student);
    Optional<StudentSubmission> findByStudentAndWorksheet(Student student, PdfWorksheet worksheet);
}
