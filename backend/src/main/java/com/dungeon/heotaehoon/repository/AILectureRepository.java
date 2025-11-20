package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.AILecture;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AILectureRepository extends JpaRepository<AILecture, Long> {
    List<AILecture> findByIsActiveTrueOrderByCreatedAtDesc();
    List<AILecture> findByTopicContainingIgnoreCase(String topic);
}
