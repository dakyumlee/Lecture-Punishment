package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Worksheet;
import com.dungeon.heotaehoon.entity.Question;
import com.dungeon.heotaehoon.repository.WorksheetRepository;
import com.dungeon.heotaehoon.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class WorksheetService {
    
    private final WorksheetRepository worksheetRepository;
    private final QuestionRepository questionRepository;

    public List<Map<String, Object>> getAllWorksheetsWithDetails(String groupId) {
        List<Worksheet> worksheets;
        
        if (groupId != null && !groupId.isEmpty()) {
            worksheets = worksheetRepository.findByGroupId(groupId);
        } else {
            worksheets = worksheetRepository.findAll();
        }
        
        return worksheets.stream().map(worksheet -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", worksheet.getId());
            map.put("title", worksheet.getTitle());
            map.put("description", worksheet.getDescription());
            map.put("category", worksheet.getCategory());
            map.put("totalQuestions", questionRepository.countByWorksheetId(worksheet.getId()));
            map.put("createdAt", worksheet.getCreatedAt());
            return map;
        }).collect(Collectors.toList());
    }

    public Map<String, Object> getWorksheetWithQuestions(String id) {
        Worksheet worksheet = worksheetRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Worksheet not found"));
        
        List<Question> questions = questionRepository.findByWorksheetOrderByQuestionNumberAsc(worksheet);
        
        Map<String, Object> result = new HashMap<>();
        result.put("worksheet", worksheet);
        result.put("questions", questions);
        
        return result;
    }

    @Transactional
    public Worksheet createWorksheet(String title, String description, String category, String groupId, List<Map<String, Object>> questionsData) {
        Worksheet worksheet = Worksheet.builder()
                .title(title)
                .description(description)
                .category(category)
                .groupId(groupId)
                .createdAt(LocalDateTime.now())
                .build();
        
        worksheet = worksheetRepository.save(worksheet);
        
        for (Map<String, Object> questionData : questionsData) {
            Question question = Question.builder()
                    .worksheet(worksheet)
                    .questionNumber((Integer) questionData.getOrDefault("questionNumber", 1))
                    .questionType((String) questionData.getOrDefault("questionType", "multiple_choice"))
                    .questionText((String) questionData.get("questionText"))
                    .optionA((String) questionData.get("optionA"))
                    .optionB((String) questionData.get("optionB"))
                    .optionC((String) questionData.get("optionC"))
                    .optionD((String) questionData.get("optionD"))
                    .correctAnswer((String) questionData.getOrDefault("correctAnswer", "1"))
                    .points((Integer) questionData.getOrDefault("points", 10))
                    .build();
            
            questionRepository.save(question);
        }
        
        return worksheet;
    }

    @Transactional
    public void deleteWorksheet(String id) {
        Worksheet worksheet = worksheetRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Worksheet not found"));
        
        questionRepository.deleteByWorksheet(worksheet);
        worksheetRepository.delete(worksheet);
    }
}
