package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Boss;
import com.dungeon.heotaehoon.entity.Lesson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BossRepository extends JpaRepository<Boss, String> {
    
    Optional<Boss> findByLesson(Lesson lesson);
    
    List<Boss> findByLessonId(String lessonId);
    
    List<Boss> findByIsDefeated(Boolean isDefeated);
}