package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.QuizAttempt;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface QuizAttemptRepository extends JpaRepository<QuizAttempt, UUID> {
    
    List<QuizAttempt> findByStudent(Student student);
    
    List<QuizAttempt> findByQuiz(Quiz quiz);
    
    List<QuizAttempt> findByStudentAndIsCorrect(Student student, Boolean isCorrect);
    
    @Query("SELECT COUNT(qa) FROM QuizAttempt qa WHERE qa.student = :student AND qa.isCorrect = true")
    Long countCorrectByStudent(Student student);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.student = :student ORDER BY qa.attemptTime DESC")
    List<QuizAttempt> findRecentAttemptsByStudent(Student student);
}
