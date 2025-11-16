package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.QuizResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuizResultRepository extends JpaRepository<QuizResult, String> {
    List<QuizResult> findByStudentId(String studentId);
    List<QuizResult> findByQuizId(String quizId);
    List<QuizResult> findByStudentIdAndIsCorrect(String studentId, Boolean isCorrect);
}
