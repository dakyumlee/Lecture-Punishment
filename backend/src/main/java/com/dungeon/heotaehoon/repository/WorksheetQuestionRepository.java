package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Worksheet;
import com.dungeon.heotaehoon.entity.WorksheetQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorksheetQuestionRepository extends JpaRepository<WorksheetQuestion, String> {
    List<WorksheetQuestion> findByWorksheetOrderByQuestionNumberAsc(Worksheet worksheet);
    Long countByWorksheetId(String worksheetId);
    void deleteByWorksheet(Worksheet worksheet);
}
