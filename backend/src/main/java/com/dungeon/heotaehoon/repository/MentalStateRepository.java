package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.MentalState;
import com.dungeon.heotaehoon.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface MentalStateRepository extends JpaRepository<MentalState, Long> {
    Optional<MentalState> findByStudent(Student student);
    Optional<MentalState> findByStudentId(String studentId);
}
