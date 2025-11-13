package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.StudentGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface StudentRepository extends JpaRepository<Student, String> {
    Optional<Student> findByUsername(String username);
    List<Student> findTop10ByOrderByExpDesc();
    List<Student> findByGroup(StudentGroup group);
}
