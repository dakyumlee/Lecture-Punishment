package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, String> {
    Optional<Student> findByUsername(String username);
}
