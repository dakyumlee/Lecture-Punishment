package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.service.OcrService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;

@Slf4j
@RestController
@RequestMapping("/api/ocr")
@RequiredArgsConstructor
public class OcrController {
    
    private final OcrService ocrService;

    @PostMapping("/extract")
    public ResponseEntity<Map<String, Object>> extractQuestions(@RequestParam("file") MultipartFile file) {
        log.info("OCR extraction request for file: {}", file.getOriginalFilename());
        
        try {
            List<OcrService.QuestionData> questions = ocrService.extractQuestionsFromPdf(file);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("questions", questions);
            response.put("count", questions.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("OCR extraction failed", e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "OCR 처리 실패: " + e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }
}
