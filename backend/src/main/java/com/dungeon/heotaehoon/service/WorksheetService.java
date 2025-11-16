package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Worksheet;
import com.dungeon.heotaehoon.entity.WorksheetQuestion;
import com.dungeon.heotaehoon.repository.WorksheetQuestionRepository;
import com.dungeon.heotaehoon.repository.WorksheetRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class WorksheetService {

    private final WorksheetRepository worksheetRepository;
    private final WorksheetQuestionRepository questionRepository;

    public List<Worksheet> getAllWorksheets() {
        return worksheetRepository.findAll();
    }

    public Worksheet getWorksheetById(String id) {
        return worksheetRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("문제지를 찾을 수 없습니다"));
    }

    public List<WorksheetQuestion> getQuestionsByWorksheetId(String worksheetId) {
        Worksheet worksheet = getWorksheetById(worksheetId);
        return questionRepository.findByWorksheetOrderByQuestionNumberAsc(worksheet);
    }

    public Long getQuestionCount(String worksheetId) {
        return questionRepository.countByWorksheetId(worksheetId);
    }

    @Transactional
    public Worksheet createWorksheet(String title, String description, String category, List<Map<String, Object>> questions, MultipartFile originalFile) {
        log.info("Creating worksheet with {} questions", questions.size());
        
        Worksheet.WorksheetBuilder worksheetBuilder = Worksheet.builder()
                .title(title)
                .description(description)
                .category(category != null && !category.trim().isEmpty() ? category : "기타")
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now());
        
        if (originalFile != null && !originalFile.isEmpty()) {
            try {
                worksheetBuilder
                    .originalFile(originalFile.getBytes())
                    .originalFileName(originalFile.getOriginalFilename())
                    .originalFileType(originalFile.getContentType());
                log.info("Original file saved: {}", originalFile.getOriginalFilename());
            } catch (IOException e) {
                log.error("Failed to save original file", e);
            }
        }
        
        Worksheet worksheet = worksheetBuilder.build();
        worksheet = worksheetRepository.save(worksheet);
        log.info("Worksheet saved with ID: {}", worksheet.getId());
        
        int savedCount = 0;
        for (Map<String, Object> qData : questions) {
            try {
                WorksheetQuestion question = WorksheetQuestion.builder()
                        .worksheet(worksheet)
                        .questionNumber(getInteger(qData, "questionNumber"))
                        .questionType((String) qData.get("questionType"))
                        .questionText((String) qData.get("questionText"))
                        .optionA((String) qData.get("optionA"))
                        .optionB((String) qData.get("optionB"))
                        .optionC((String) qData.get("optionC"))
                        .optionD((String) qData.get("optionD"))
                        .correctAnswer((String) qData.get("correctAnswer"))
                        .points(getInteger(qData, "points"))
                        .build();
                
                questionRepository.save(question);
                savedCount++;
                log.info("Question {} saved successfully", savedCount);
            } catch (Exception e) {
                log.error("Failed to save question {}: {}", savedCount + 1, e.getMessage(), e);
                throw e;
            }
        }
        
        log.info("Total {} questions saved for worksheet {}", savedCount, worksheet.getId());
        return worksheet;
    }

    @Transactional
    public WorksheetQuestion addQuestion(String worksheetId, Map<String, Object> questionData) {
        Worksheet worksheet = getWorksheetById(worksheetId);
        
        WorksheetQuestion question = WorksheetQuestion.builder()
                .worksheet(worksheet)
                .questionNumber(getInteger(questionData, "questionNumber"))
                .questionType((String) questionData.get("questionType"))
                .questionText((String) questionData.get("questionText"))
                .optionA((String) questionData.get("optionA"))
                .optionB((String) questionData.get("optionB"))
                .optionC((String) questionData.get("optionC"))
                .optionD((String) questionData.get("optionD"))
                .correctAnswer((String) questionData.get("correctAnswer"))
                .points(getInteger(questionData, "points"))
                .build();
        
        return questionRepository.save(question);
    }

    @Transactional
    public void deleteWorksheet(String id) {
        Worksheet worksheet = getWorksheetById(id);
        questionRepository.deleteByWorksheet(worksheet);
        worksheetRepository.delete(worksheet);
    }

    @Transactional
    public void deleteQuestion(String questionId) {
        questionRepository.deleteById(questionId);
    }

    public byte[] getOriginalFile(String worksheetId) {
        Worksheet worksheet = getWorksheetById(worksheetId);
        if (worksheet.getOriginalFile() == null) {
            throw new RuntimeException("원본 파일이 없습니다");
        }
        return worksheet.getOriginalFile();
    }

    public String getOriginalFileName(String worksheetId) {
        Worksheet worksheet = getWorksheetById(worksheetId);
        return worksheet.getOriginalFileName();
    }

    public String getOriginalFileType(String worksheetId) {
        Worksheet worksheet = getWorksheetById(worksheetId);
        return worksheet.getOriginalFileType();
    }

    private Integer getInteger(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value == null) return null;
        if (value instanceof Integer) return (Integer) value;
        if (value instanceof String) {
            try {
                return Integer.parseInt((String) value);
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }
}
