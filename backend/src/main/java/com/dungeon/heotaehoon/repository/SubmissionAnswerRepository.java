package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.SubmissionAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface SubmissionAnswerRepository extends JpaRepository<SubmissionAnswer, String> {
    List<SubmissionAnswer> findBySubmissionId(String submissionId);
}
