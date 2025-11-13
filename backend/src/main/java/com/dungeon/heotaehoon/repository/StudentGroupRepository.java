package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.StudentGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface StudentGroupRepository extends JpaRepository<StudentGroup, String> {
    List<StudentGroup> findByIsActiveTrue();
    List<StudentGroup> findByYear(Integer year);
    List<StudentGroup> findByCourse(String course);
}
