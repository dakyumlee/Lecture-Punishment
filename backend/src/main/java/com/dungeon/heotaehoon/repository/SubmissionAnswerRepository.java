package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.SubmissionAnswer;
import com.dungeon.heotaehoon.entity.StudentSubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SubmissionAnswerRepository extends JpaRepository<SubmissionAnswer, String> {
    List<SubmissionAnswer> findBySubmission(StudentSubmission submission);
}
