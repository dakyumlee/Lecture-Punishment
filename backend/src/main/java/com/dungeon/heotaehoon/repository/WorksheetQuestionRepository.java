package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.PdfWorksheet;
import com.dungeon.heotaehoon.entity.WorksheetQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorksheetQuestionRepository extends JpaRepository<WorksheetQuestion, String> {
    List<WorksheetQuestion> findByWorksheet_IdOrderByQuestionNumber(String worksheetId);
    List<WorksheetQuestion> findByWorksheetOrderByQuestionNumberAsc(PdfWorksheet worksheet);
}
