package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Question;
import com.dungeon.heotaehoon.entity.Worksheet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, String> {
    List<Question> findByWorksheetOrderByQuestionNumberAsc(Worksheet worksheet);
    Long countByWorksheetId(String worksheetId);
    void deleteByWorksheet(Worksheet worksheet);
}
