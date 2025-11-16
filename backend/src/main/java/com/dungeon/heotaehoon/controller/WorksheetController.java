package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Worksheet;
import com.dungeon.heotaehoon.service.WorksheetService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/worksheets")
@RequiredArgsConstructor
public class WorksheetController {
    
    private final WorksheetService worksheetService;

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getAllWorksheets(
            @RequestParam(required = false) String groupId) {
        log.info("Fetching worksheets for groupId: {}", groupId);
        List<Map<String, Object>> worksheets = worksheetService.getAllWorksheetsWithDetails(groupId);
        return ResponseEntity.ok(worksheets);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getWorksheetWithQuestions(@PathVariable String id) {
        log.info("Fetching worksheet with questions: {}", id);
        Map<String, Object> worksheet = worksheetService.getWorksheetWithQuestions(id);
        return ResponseEntity.ok(worksheet);
    }

    @PostMapping
    public ResponseEntity<Worksheet> createWorksheet(@RequestBody Map<String, Object> request) {
        String title = (String) request.get("title");
        String description = (String) request.get("description");
        String category = (String) request.getOrDefault("category", "기타");
        String groupId = (String) request.get("groupId");
        List<Map<String, Object>> questions = (List<Map<String, Object>>) request.get("questions");
        
        log.info("Creating worksheet: {} with {} questions for group: {}", title, questions.size(), groupId);
        
        Worksheet worksheet = worksheetService.createWorksheet(title, description, category, groupId, questions);
        return ResponseEntity.ok(worksheet);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteWorksheet(@PathVariable String id) {
        log.info("Deleting worksheet: {}", id);
        worksheetService.deleteWorksheet(id);
        return ResponseEntity.ok().build();
    }
}
