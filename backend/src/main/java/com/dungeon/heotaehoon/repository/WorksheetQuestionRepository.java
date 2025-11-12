package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.WorksheetQuestion;
import com.dungeon.heotaehoon.entity.PdfWorksheet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorksheetQuestionRepository extends JpaRepository<WorksheetQuestion, String> {
    List<WorksheetQuestion> findByWorksheetOrderByQuestionNumber(PdfWorksheet worksheet);
    List<WorksheetQuestion> findByWorksheetIdOrderByQuestionNumber(String worksheetId);
}
