package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.WorksheetQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorksheetQuestionRepository extends JpaRepository<WorksheetQuestion, Long> {
    List<WorksheetQuestion> findByWorksheet_IdOrderByQuestionOrder(Long worksheetId);
}
