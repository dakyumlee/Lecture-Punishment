package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.service.OcrService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/ocr")
@RequiredArgsConstructor
public class OcrController {

    private final OcrService ocrService;

    @PostMapping("/extract")
    public ResponseEntity<Map<String, Object>> extractQuestions(@RequestParam("file") MultipartFile file) {
        log.info("OCR extraction request received - File: {}, Size: {}", 
            file.getOriginalFilename(), file.getSize());
        
        try {
            if (file.isEmpty()) {
                log.error("Empty file received");
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("error", "파일이 비어있습니다");
                return ResponseEntity.badRequest().body(error);
            }

            if (!file.getOriginalFilename().toLowerCase().endsWith(".pdf")) {
                log.error("Invalid file type: {}", file.getOriginalFilename());
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("error", "PDF 파일만 업로드 가능합니다");
                return ResponseEntity.badRequest().body(error);
            }

            List<OcrService.QuestionData> questions = ocrService.extractQuestionsFromPdf(file);
            
            log.info("Successfully extracted {} questions", questions.size());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("questions", questions);
            response.put("count", questions.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("OCR extraction failed", e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            error.put("details", e.getClass().getName());
            return ResponseEntity.badRequest().body(error);
        }
    }
}
