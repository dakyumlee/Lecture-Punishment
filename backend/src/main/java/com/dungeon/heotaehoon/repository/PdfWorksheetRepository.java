package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.PdfWorksheet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PdfWorksheetRepository extends JpaRepository<PdfWorksheet, String> {
}
