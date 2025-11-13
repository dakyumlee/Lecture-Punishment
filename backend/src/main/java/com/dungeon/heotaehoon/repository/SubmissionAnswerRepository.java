package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.SubmissionAnswer;
import com.dungeon.heotaehoon.entity.StudentSubmission;
import com.dungeon.heotaehoon.entity.WorksheetQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SubmissionAnswerRepository extends JpaRepository<SubmissionAnswer, Long> {
    List<SubmissionAnswer> findBySubmission(StudentSubmission submission);
    List<SubmissionAnswer> findByQuestion(WorksheetQuestion question);
    List<SubmissionAnswer> findBySubmission_Id(Long submissionId);
}
