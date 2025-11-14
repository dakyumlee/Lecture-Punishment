package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Instructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface InstructorRepository extends JpaRepository<Instructor, String> {
    Optional<Instructor> findByName(String name);
    Optional<Instructor> findByUsername(String username);
}
