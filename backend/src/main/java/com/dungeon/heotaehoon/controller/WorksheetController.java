package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.PdfWorksheet;
import com.dungeon.heotaehoon.entity.WorksheetQuestion;
import com.dungeon.heotaehoon.entity.WorksheetCategory;
import com.dungeon.heotaehoon.repository.WorksheetCategoryRepository;
import com.dungeon.heotaehoon.service.WorksheetService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/worksheets")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class WorksheetController {

    private final WorksheetService worksheetService;
    private final WorksheetCategoryRepository categoryRepository;

    @PostMapping
    public ResponseEntity<PdfWorksheet> createWorksheet(@RequestBody Map<String, Object> worksheetData) {
        PdfWorksheet worksheet = worksheetService.createWorksheet(worksheetData);
        return ResponseEntity.ok(worksheet);
    }

    @PostMapping("/{worksheetId}/questions")
    public ResponseEntity<WorksheetQuestion> addQuestion(
        @PathVariable String worksheetId,
        @RequestBody Map<String, Object> questionData
    ) {
        WorksheetQuestion question = worksheetService.addQuestion(worksheetId, questionData);
        return ResponseEntity.ok(question);
    }

    @GetMapping
    public ResponseEntity<List<PdfWorksheet>> getAllWorksheets() {
        List<PdfWorksheet> worksheets = worksheetService.getAllActiveWorksheets();
        return ResponseEntity.ok(worksheets);
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<List<PdfWorksheet>> getWorksheetsByCategory(@PathVariable String category) {
        List<PdfWorksheet> worksheets = worksheetService.getWorksheetsByCategory(category);
        return ResponseEntity.ok(worksheets);
    }

    @GetMapping("/{worksheetId}")
    public ResponseEntity<Map<String, Object>> getWorksheet(@PathVariable String worksheetId) {
        Map<String, Object> worksheet = worksheetService.getWorksheetWithQuestions(worksheetId);
        return ResponseEntity.ok(worksheet);
    }

    @PostMapping("/{worksheetId}/submit")
    public ResponseEntity<Map<String, Object>> submitWorksheet(
        @PathVariable String worksheetId,
        @RequestBody Map<String, Object> submissionData
    ) {
        String studentId = (String) submissionData.get("studentId");
        List<Map<String, String>> answers = (List<Map<String, String>>) submissionData.get("answers");
        
        Map<String, Object> result = worksheetService.submitWorksheet(studentId, worksheetId, answers);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/student/{studentId}/submissions")
    public ResponseEntity<List<Map<String, Object>>> getStudentSubmissions(@PathVariable String studentId) {
        List<Map<String, Object>> submissions = worksheetService.getStudentSubmissions(studentId);
        return ResponseEntity.ok(submissions);
    }

    @GetMapping("/categories")
    public ResponseEntity<List<WorksheetCategory>> getAllCategories() {
        List<WorksheetCategory> categories = categoryRepository.findAll();
        return ResponseEntity.ok(categories);
    }

    @PostMapping("/categories")
    public ResponseEntity<WorksheetCategory> createCategory(@RequestBody WorksheetCategory category) {
        WorksheetCategory saved = categoryRepository.save(category);
        return ResponseEntity.ok(saved);
    }
}
