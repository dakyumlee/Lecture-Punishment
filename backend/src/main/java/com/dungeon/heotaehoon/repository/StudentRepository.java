package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.StudentGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, String> {
    Optional<Student> findByUsername(String username);
    Optional<Student> findByDisplayName(String displayName);
    List<Student> findAllByDisplayName(String displayName);
    List<Student> findByGroup(StudentGroup group);
    List<Student> findByGroup_Id(String groupId);
    List<Student> findTop10ByOrderByExpDesc();
}
