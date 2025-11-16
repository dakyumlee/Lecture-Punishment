package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Worksheet;
import com.dungeon.heotaehoon.entity.WorksheetQuestion;
import com.dungeon.heotaehoon.service.WorksheetService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@Slf4j
@RestController
@RequestMapping("/api/worksheets")
@RequiredArgsConstructor
public class WorksheetController {

    private final WorksheetService worksheetService;

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getAllWorksheets() {
        try {
            List<Worksheet> worksheets = worksheetService.getAllWorksheets();
            List<Map<String, Object>> response = new ArrayList<>();
            
            for (Worksheet ws : worksheets) {
                Long questionCount = worksheetService.getQuestionCount(ws.getId());
                log.info("Worksheet {} has {} questions", ws.getId(), questionCount);
                
                Map<String, Object> wsMap = new HashMap<>();
                wsMap.put("id", ws.getId());
                wsMap.put("title", ws.getTitle());
                wsMap.put("description", ws.getDescription());
                wsMap.put("category", ws.getCategory() != null ? ws.getCategory() : "기타");
                wsMap.put("questionCount", questionCount);
                wsMap.put("createdAt", ws.getCreatedAt());
                response.add(wsMap);
            }
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to get worksheets", e);
            return ResponseEntity.status(500).body(new ArrayList<>());
        }
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createWorksheet(@RequestBody Map<String, Object> request) {
        try {
            String title = (String) request.get("title");
            String description = (String) request.get("description");
            String category = (String) request.get("category");
            
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> questions = (List<Map<String, Object>>) request.get("questions");
            
            log.info("Creating worksheet - Title: {}, Category: {}, Questions: {}", 
                title, category, questions.size());
            
            Worksheet worksheet = worksheetService.createWorksheet(title, description, category, questions);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("worksheetId", worksheet.getId());
            response.put("message", "문제지가 생성되었습니다");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to create worksheet", e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getWorksheet(@PathVariable String id) {
        try {
            Worksheet worksheet = worksheetService.getWorksheetById(id);
            List<WorksheetQuestion> questions = worksheetService.getQuestionsByWorksheetId(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("id", worksheet.getId());
            response.put("title", worksheet.getTitle());
            response.put("description", worksheet.getDescription());
            response.put("category", worksheet.getCategory() != null ? worksheet.getCategory() : "기타");
            response.put("createdAt", worksheet.getCreatedAt());
            
            List<Map<String, Object>> questionList = new ArrayList<>();
            for (WorksheetQuestion q : questions) {
                Map<String, Object> qMap = new HashMap<>();
                qMap.put("id", q.getId());
                qMap.put("questionNumber", q.getQuestionNumber());
                qMap.put("questionText", q.getQuestionText());
                qMap.put("questionType", q.getQuestionType());
                qMap.put("optionA", q.getOptionA());
                qMap.put("optionB", q.getOptionB());
                qMap.put("optionC", q.getOptionC());
                qMap.put("optionD", q.getOptionD());
                qMap.put("correctAnswer", q.getCorrectAnswer());
                qMap.put("points", q.getPoints());
                questionList.add(qMap);
            }
            
            response.put("questions", questionList);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to get worksheet", e);
            return ResponseEntity.status(404).body(new HashMap<>());
        }
    }

    @GetMapping("/{id}/questions")
    public ResponseEntity<List<Map<String, Object>>> getWorksheetQuestions(@PathVariable String id) {
        try {
            List<WorksheetQuestion> questions = worksheetService.getQuestionsByWorksheetId(id);
            
            List<Map<String, Object>> questionList = new ArrayList<>();
            for (WorksheetQuestion q : questions) {
                Map<String, Object> qMap = new HashMap<>();
                qMap.put("id", q.getId());
                qMap.put("questionNumber", q.getQuestionNumber());
                qMap.put("questionText", q.getQuestionText());
                qMap.put("questionType", q.getQuestionType());
                qMap.put("optionA", q.getOptionA());
                qMap.put("optionB", q.getOptionB());
                qMap.put("optionC", q.getOptionC());
                qMap.put("optionD", q.getOptionD());
                qMap.put("correctAnswer", q.getCorrectAnswer());
                qMap.put("points", q.getPoints());
                questionList.add(qMap);
            }
            
            return ResponseEntity.ok(questionList);
        } catch (Exception e) {
            log.error("Failed to get worksheet questions", e);
            return ResponseEntity.status(500).body(new ArrayList<>());
        }
    }

    @GetMapping("/{id}/view")
    public ResponseEntity<Map<String, Object>> viewWorksheet(@PathVariable String id) {
        try {
            Worksheet worksheet = worksheetService.getWorksheetById(id);
            List<WorksheetQuestion> questions = worksheetService.getQuestionsByWorksheetId(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("id", worksheet.getId());
            response.put("title", worksheet.getTitle());
            response.put("description", worksheet.getDescription());
            response.put("category", worksheet.getCategory() != null ? worksheet.getCategory() : "기타");
            response.put("createdAt", worksheet.getCreatedAt());
            
            List<Map<String, Object>> questionList = new ArrayList<>();
            for (WorksheetQuestion q : questions) {
                Map<String, Object> qMap = new HashMap<>();
                qMap.put("questionNumber", q.getQuestionNumber());
                qMap.put("questionText", q.getQuestionText());
                qMap.put("questionType", q.getQuestionType());
                qMap.put("optionA", q.getOptionA());
                qMap.put("optionB", q.getOptionB());
                qMap.put("optionC", q.getOptionC());
                qMap.put("optionD", q.getOptionD());
                questionList.add(qMap);
            }
            
            response.put("questions", questionList);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to view worksheet", e);
            return ResponseEntity.status(404).body(new HashMap<>());
        }
    }

    @GetMapping("/{id}/pdf")
    public ResponseEntity<byte[]> getPdf(@PathVariable String id) {
        try {
            Worksheet worksheet = worksheetService.getWorksheetById(id);
            List<WorksheetQuestion> questions = worksheetService.getQuestionsByWorksheetId(id);
            
            StringBuilder content = new StringBuilder();
            content.append("=".repeat(80)).append("\n");
            content.append(worksheet.getTitle()).append("\n");
            if (worksheet.getDescription() != null) {
                content.append(worksheet.getDescription()).append("\n");
            }
            content.append("카테고리: ").append(worksheet.getCategory() != null ? worksheet.getCategory() : "기타").append("\n");
            content.append("=".repeat(80)).append("\n\n");
            
            for (WorksheetQuestion q : questions) {
                content.append(q.getQuestionNumber()).append(". ").append(q.getQuestionText()).append("\n\n");
                
                if ("multiple_choice".equals(q.getQuestionType())) {
                    if (q.getOptionA() != null) content.append("  1) ").append(q.getOptionA()).append("\n");
                    if (q.getOptionB() != null) content.append("  2) ").append(q.getOptionB()).append("\n");
                    if (q.getOptionC() != null) content.append("  3) ").append(q.getOptionC()).append("\n");
                    if (q.getOptionD() != null) content.append("  4) ").append(q.getOptionD()).append("\n");
                }
                
                content.append("\n");
            }
            
            byte[] bytes = content.toString().getBytes("UTF-8");
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.TEXT_PLAIN);
            headers.setContentDispositionFormData("inline", worksheet.getTitle() + ".txt");
            headers.setContentLength(bytes.length);
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(bytes);
        } catch (Exception e) {
            log.error("Failed to get pdf", e);
            return ResponseEntity.status(500).body(new byte[0]);
        }
    }

    @GetMapping("/{id}/download")
    public ResponseEntity<byte[]> downloadWorksheet(@PathVariable String id) {
        try {
            Worksheet worksheet = worksheetService.getWorksheetById(id);
            List<WorksheetQuestion> questions = worksheetService.getQuestionsByWorksheetId(id);
            
            StringBuilder content = new StringBuilder();
            content.append("=".repeat(80)).append("\n");
            content.append(worksheet.getTitle()).append("\n");
            if (worksheet.getDescription() != null) {
                content.append(worksheet.getDescription()).append("\n");
            }
            content.append("카테고리: ").append(worksheet.getCategory() != null ? worksheet.getCategory() : "기타").append("\n");
            content.append("=".repeat(80)).append("\n\n");
            
            for (WorksheetQuestion q : questions) {
                content.append(q.getQuestionNumber()).append(". ").append(q.getQuestionText()).append("\n\n");
                
                if ("multiple_choice".equals(q.getQuestionType())) {
                    if (q.getOptionA() != null) content.append("  1) ").append(q.getOptionA()).append("\n");
                    if (q.getOptionB() != null) content.append("  2) ").append(q.getOptionB()).append("\n");
                    if (q.getOptionC() != null) content.append("  3) ").append(q.getOptionC()).append("\n");
                    if (q.getOptionD() != null) content.append("  4) ").append(q.getOptionD()).append("\n");
                }
                
                content.append("\n");
            }
            
            byte[] bytes = content.toString().getBytes("UTF-8");
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.TEXT_PLAIN);
            headers.setContentDispositionFormData("attachment", worksheet.getTitle() + ".txt");
            headers.setContentLength(bytes.length);
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(bytes);
        } catch (Exception e) {
            log.error("Failed to download worksheet", e);
            return ResponseEntity.status(500).body(new byte[0]);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteWorksheet(@PathVariable String id) {
        try {
            log.info("Deleting worksheet: {}", id);
            worksheetService.deleteWorksheet(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "문제지가 삭제되었습니다");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to delete worksheet: {}", id, e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    @PostMapping("/{worksheetId}/questions")
    public ResponseEntity<Map<String, Object>> addQuestion(
            @PathVariable String worksheetId,
            @RequestBody Map<String, Object> questionData) {
        try {
            WorksheetQuestion question = worksheetService.addQuestion(worksheetId, questionData);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("questionId", question.getId());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to add question", e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    @DeleteMapping("/{worksheetId}/questions/{questionId}")
    public ResponseEntity<Map<String, Object>> deleteQuestion(
            @PathVariable String worksheetId,
            @PathVariable String questionId) {
        try {
            worksheetService.deleteQuestion(questionId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to delete question", e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }
}
