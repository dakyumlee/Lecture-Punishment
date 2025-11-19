package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.StudentCustomization;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface StudentCustomizationRepository extends JpaRepository<StudentCustomization, Long> {
    List<StudentCustomization> findByStudentId(String studentId);
    Optional<StudentCustomization> findByStudentIdAndItemId(String studentId, Long itemId);
}
