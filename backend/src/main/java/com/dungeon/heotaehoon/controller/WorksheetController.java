package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Worksheet;
import com.dungeon.heotaehoon.entity.WorksheetQuestion;
import com.dungeon.heotaehoon.service.WorksheetService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType0Font;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.*;

@Slf4j
@RestController
@RequestMapping("/api/worksheets")
@RequiredArgsConstructor
public class WorksheetController {

    private final WorksheetService worksheetService;
    private final ObjectMapper objectMapper;

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
                wsMap.put("hasOriginalFile", ws.getOriginalFile() != null);
                wsMap.put("originalFileName", ws.getOriginalFileName());
                response.add(wsMap);
            }
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to get worksheets", e);
            return ResponseEntity.status(500).body(new ArrayList<>());
        }
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, Object>> createWorksheet(
            @RequestParam("title") String title,
            @RequestParam("description") String description,
            @RequestParam("category") String category,
            @RequestParam("questions") String questionsJson,
            @RequestParam(value = "originalFile", required = false) MultipartFile originalFile) {
        try {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> questions = objectMapper.readValue(questionsJson, List.class);
            
            log.info("Creating worksheet - Title: {}, Category: {}, Questions: {}, Has File: {}", 
                title, category, questions.size(), originalFile != null);
            
            Worksheet worksheet = worksheetService.createWorksheet(title, description, category, questions, originalFile);
            
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
            response.put("hasOriginalFile", worksheet.getOriginalFile() != null);
            response.put("originalFileName", worksheet.getOriginalFileName());
            
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

    @GetMapping("/{id}/original")
    public ResponseEntity<byte[]> viewOriginalFile(@PathVariable String id) {
        try {
            byte[] fileData = worksheetService.getOriginalFile(id);
            String fileName = worksheetService.getOriginalFileName(id);
            String fileType = worksheetService.getOriginalFileType(id);
            
            String encodedFileName = java.net.URLEncoder.encode(fileName, "UTF-8")
                .replaceAll("\\+", "%20");
            
            HttpHeaders headers = new HttpHeaders();
            if (fileType != null) {
                headers.setContentType(MediaType.parseMediaType(fileType));
            } else {
                headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            }
            headers.set(HttpHeaders.CONTENT_DISPOSITION, 
                "inline; filename*=UTF-8''" + encodedFileName);
            headers.setContentLength(fileData.length);
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(fileData);
        } catch (Exception e) {
            log.error("Failed to view original file", e);
            return ResponseEntity.status(404).body(new byte[0]);
        }
    }

    @GetMapping("/{id}/original/download")
    public ResponseEntity<byte[]> downloadOriginalFile(@PathVariable String id) {
        try {
            byte[] fileData = worksheetService.getOriginalFile(id);
            String fileName = worksheetService.getOriginalFileName(id);
            String fileType = worksheetService.getOriginalFileType(id);
            
            String encodedFileName = java.net.URLEncoder.encode(fileName, "UTF-8")
                .replaceAll("\\+", "%20");
            
            HttpHeaders headers = new HttpHeaders();
            if (fileType != null) {
                headers.setContentType(MediaType.parseMediaType(fileType));
            } else {
                headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            }
            headers.set(HttpHeaders.CONTENT_DISPOSITION, 
                "attachment; filename*=UTF-8''" + encodedFileName);
            headers.setContentLength(fileData.length);
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(fileData);
        } catch (Exception e) {
            log.error("Failed to download original file", e);
            return ResponseEntity.status(404).body(new byte[0]);
        }
    }

    @GetMapping("/{id}/pdf")
    public ResponseEntity<byte[]> getPdf(@PathVariable String id) {
        try {
            Worksheet worksheet = worksheetService.getWorksheetById(id);
            List<WorksheetQuestion> questions = worksheetService.getQuestionsByWorksheetId(id);
            
            byte[] pdfBytes = generatePdf(worksheet, questions);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.set(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + worksheet.getTitle() + ".pdf\"");
            headers.setContentLength(pdfBytes.length);
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(pdfBytes);
        } catch (Exception e) {
            log.error("Failed to get PDF", e);
            return ResponseEntity.status(500).body(new byte[0]);
        }
    }

    @GetMapping("/{id}/download")
    public ResponseEntity<byte[]> downloadPdf(@PathVariable String id) {
        try {
            Worksheet worksheet = worksheetService.getWorksheetById(id);
            List<WorksheetQuestion> questions = worksheetService.getQuestionsByWorksheetId(id);
            
            byte[] pdfBytes = generatePdf(worksheet, questions);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + worksheet.getTitle() + ".pdf\"");
            headers.setContentLength(pdfBytes.length);
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(pdfBytes);
        } catch (Exception e) {
            log.error("Failed to download PDF", e);
            return ResponseEntity.status(500).body(new byte[0]);
        }
    }

    private byte[] generatePdf(Worksheet worksheet, List<WorksheetQuestion> questions) throws Exception {
        PDDocument document = new PDDocument();
        
        try {
            PDPage page = new PDPage(PDRectangle.A4);
            document.addPage(page);
            
            PDPageContentStream contentStream = new PDPageContentStream(document, page);
            
            float margin = 50;
            float yPosition = page.getMediaBox().getHeight() - margin;
            float leading = 15f;
            
            PDType0Font font;
            try {
                InputStream fontStream = new ClassPathResource("fonts/NanumGothic.ttf").getInputStream();
                font = PDType0Font.load(document, fontStream);
            } catch (Exception e) {
                log.warn("Korean font not found, using fallback");
                font = PDType0Font.load(document, this.getClass().getResourceAsStream("/fonts/NanumGothic.ttf"));
            }
            
            contentStream.beginText();
            contentStream.setFont(font, 18);
            contentStream.newLineAtOffset(margin, yPosition);
            contentStream.showText(worksheet.getTitle());
            contentStream.endText();
            
            yPosition -= 30;
            
            if (worksheet.getDescription() != null && !worksheet.getDescription().isEmpty()) {
                contentStream.beginText();
                contentStream.setFont(font, 11);
                contentStream.newLineAtOffset(margin, yPosition);
                contentStream.showText(worksheet.getDescription());
                contentStream.endText();
                yPosition -= 25;
            }
            
            String categoryText = "카테고리: " + (worksheet.getCategory() != null ? worksheet.getCategory() : "기타");
            contentStream.beginText();
            contentStream.setFont(font, 10);
            contentStream.newLineAtOffset(margin, yPosition);
            contentStream.showText(categoryText);
            contentStream.endText();
            
            yPosition -= 40;
            
            for (WorksheetQuestion q : questions) {
                if (yPosition < margin + 150) {
                    contentStream.close();
                    page = new PDPage(PDRectangle.A4);
                    document.addPage(page);
                    contentStream = new PDPageContentStream(document, page);
                    yPosition = page.getMediaBox().getHeight() - margin;
                }
                
                String questionText = q.getQuestionNumber() + ". " + q.getQuestionText();
                contentStream.beginText();
                contentStream.setFont(font, 12);
                contentStream.newLineAtOffset(margin, yPosition);
                contentStream.showText(questionText);
                contentStream.endText();
                
                yPosition -= 25;
                
                if ("multiple_choice".equals(q.getQuestionType())) {
                    contentStream.setFont(font, 11);
                    
                    if (q.getOptionA() != null) {
                        contentStream.beginText();
                        contentStream.newLineAtOffset(margin + 20, yPosition);
                        contentStream.showText("1) " + q.getOptionA());
                        contentStream.endText();
                        yPosition -= leading;
                    }
                    if (q.getOptionB() != null) {
                        contentStream.beginText();
                        contentStream.newLineAtOffset(margin + 20, yPosition);
                        contentStream.showText("2) " + q.getOptionB());
                        contentStream.endText();
                        yPosition -= leading;
                    }
                    if (q.getOptionC() != null) {
                        contentStream.beginText();
                        contentStream.newLineAtOffset(margin + 20, yPosition);
                        contentStream.showText("3) " + q.getOptionC());
                        contentStream.endText();
                        yPosition -= leading;
                    }
                    if (q.getOptionD() != null) {
                        contentStream.beginText();
                        contentStream.newLineAtOffset(margin + 20, yPosition);
                        contentStream.showText("4) " + q.getOptionD());
                        contentStream.endText();
                        yPosition -= leading;
                    }
                }
                
                yPosition -= 25;
            }
            
            contentStream.close();
            
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            document.save(baos);
            return baos.toByteArray();
            
        } finally {
            document.close();
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
