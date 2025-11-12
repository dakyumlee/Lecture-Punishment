package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.StudentAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StudentAnswerRepository extends JpaRepository<StudentAnswer, String> {
    List<StudentAnswer> findTop10ByStudentIdOrderByAnsweredAtDesc(String studentId);
    List<StudentAnswer> findByStudentId(String studentId);
}
