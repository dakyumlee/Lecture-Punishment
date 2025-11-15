package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Lesson;
import com.dungeon.heotaehoon.entity.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuizRepository extends JpaRepository<Quiz, String> {
    List<Quiz> findTop5ByLessonOrderByCreatedAtDesc(Lesson lesson);
    List<Quiz> findByLessonOrderByCreatedAtAsc(Lesson lesson);
    List<Quiz> findByBossId(String bossId);
    List<Quiz> findByLessonId(String lessonId);
}