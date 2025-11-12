package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.PdfWorksheet;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.StudentSubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface StudentSubmissionRepository extends JpaRepository<StudentSubmission, String> {
    List<StudentSubmission> findByStudentOrderBySubmittedAtDesc(Student student);
    List<StudentSubmission> findByWorksheet(PdfWorksheet worksheet);
}
