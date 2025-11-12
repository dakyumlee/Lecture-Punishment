package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.PdfWorksheet;
import com.dungeon.heotaehoon.entity.Instructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PdfWorksheetRepository extends JpaRepository<PdfWorksheet, String> {
    List<PdfWorksheet> findByInstructor(Instructor instructor);
    List<PdfWorksheet> findByCategory(String category);
    List<PdfWorksheet> findByIsActiveTrue();
    List<PdfWorksheet> findByCategoryAndIsActive(String category, Boolean isActive);
    Optional<PdfWorksheet> findByIdAndIsActive(String id, Boolean isActive);
}
