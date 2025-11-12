package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.PdfWorksheet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PdfWorksheetRepository extends JpaRepository<PdfWorksheet, String> {
    List<PdfWorksheet> findByIsActiveTrue();
    List<PdfWorksheet> findByCategoryOrderByCreatedAtDesc(String category);
    Optional<PdfWorksheet> findByIdAndIsActiveTrue(String id, boolean isActive);
    List<PdfWorksheet> findByCategoryAndIsActive(String category, boolean isActive);
}
