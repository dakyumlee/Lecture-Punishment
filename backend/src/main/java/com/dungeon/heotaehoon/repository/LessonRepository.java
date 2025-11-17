package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Lesson;
import com.dungeon.heotaehoon.entity.StudentGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface LessonRepository extends JpaRepository<Lesson, String> {
    Optional<Lesson> findByLessonDateAndIsActive(LocalDate lessonDate, Boolean isActive);
    List<Lesson> findByGroupAndIsActiveTrue(StudentGroup group);
    List<Lesson> findByGroupIsNullAndIsActiveTrue();
}
