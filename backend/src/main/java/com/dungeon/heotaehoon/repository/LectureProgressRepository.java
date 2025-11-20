package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.LectureProgress;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.AILecture;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

@Repository
public interface LectureProgressRepository extends JpaRepository<LectureProgress, Long> {
    Optional<LectureProgress> findByStudentAndLecture(Student student, AILecture lecture);
    List<LectureProgress> findByStudent(Student student);
}
