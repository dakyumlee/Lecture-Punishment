package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.PdfWorksheet;
import com.dungeon.heotaehoon.entity.WorksheetQuestion;
import com.dungeon.heotaehoon.service.WorksheetService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/worksheets")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class WorksheetController {

    private final WorksheetService worksheetService;

    @PostMapping
    public ResponseEntity<PdfWorksheet> createWorksheet(
            @RequestParam String title,
            @RequestParam String description,
            @RequestParam String category,
            @RequestParam("file") MultipartFile file) {
        try {
            PdfWorksheet worksheet = worksheetService.createWorksheet(title, description, category, file);
            return ResponseEntity.ok(worksheet);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/{worksheetId}/questions")
    public ResponseEntity<WorksheetQuestion> addQuestion(
            @PathVariable String worksheetId,
            @RequestBody WorksheetQuestion question) {
        WorksheetQuestion saved = worksheetService.addQuestion(worksheetId, question);
        return ResponseEntity.ok(saved);
    }

    @GetMapping
    public ResponseEntity<List<PdfWorksheet>> getAllWorksheets() {
        return ResponseEntity.ok(worksheetService.getAllActiveWorksheets());
    }

    @GetMapping("/grouped")
    public ResponseEntity<Map<String, List<PdfWorksheet>>> getWorksheetsGrouped() {
        return ResponseEntity.ok(worksheetService.getWorksheetsGroupedByCategory());
    }

    @GetMapping("/{worksheetId}")
    public ResponseEntity<Map<String, Object>> getWorksheetWithQuestions(@PathVariable String worksheetId) {
        return ResponseEntity.ok(worksheetService.getWorksheetWithQuestions(worksheetId));
    }

    @PostMapping("/{worksheetId}/submit")
    public ResponseEntity<Map<String, Object>> submitWorksheet(
            @PathVariable String worksheetId,
            @RequestBody Map<String, Object> submission) {
        String studentId = (String) submission.get("studentId");
        List<Map<String, String>> answers = (List<Map<String, String>>) submission.get("answers");
        
        Map<String, Object> result = worksheetService.submitWorksheet(studentId, worksheetId, answers);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/student/{studentId}/submissions")
    public ResponseEntity<Map<String, Object>> getStudentSubmissions(@PathVariable String studentId) {
        Map<String, Object> result = Map.of(
            "submissions", worksheetService.getStudentSubmissions(studentId)
        );
        return ResponseEntity.ok(result);
    }
}
