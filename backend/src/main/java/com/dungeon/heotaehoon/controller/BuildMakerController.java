package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.service.BuildMakerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/build-maker")
@RequiredArgsConstructor
public class BuildMakerController {
    
    private final BuildMakerService buildMakerService;
    
    @PostMapping("/generate")
    public ResponseEntity<Map<String, Object>> generateLecture(@RequestBody Map<String, Object> request) {
        Map<String, Object> result = buildMakerService.generateAILecture(request);
        return ResponseEntity.ok(result);
    }
    
    @GetMapping("/lectures")
    public ResponseEntity<List<Map<String, Object>>> getAllLectures() {
        List<Map<String, Object>> lectures = buildMakerService.getAllLectures();
        return ResponseEntity.ok(lectures);
    }
    
    @GetMapping("/lectures/{lectureId}")
    public ResponseEntity<Map<String, Object>> getLectureDetail(@PathVariable Long lectureId) {
        Map<String, Object> lecture = buildMakerService.getLectureDetail(lectureId);
        return ResponseEntity.ok(lecture);
    }
    
    @PostMapping("/progress/update")
    public ResponseEntity<Map<String, Object>> updateProgress(@RequestBody Map<String, Object> request) {
        String studentId = (String) request.get("studentId");
        Long lectureId = Long.valueOf(request.get("lectureId").toString());
        Integer currentSection = (Integer) request.get("currentSection");
        
        Map<String, Object> result = buildMakerService.updateProgress(studentId, lectureId, currentSection);
        return ResponseEntity.ok(result);
    }
    
    @GetMapping("/progress/{studentId}/{lectureId}")
    public ResponseEntity<Map<String, Object>> getProgress(
        @PathVariable String studentId,
        @PathVariable Long lectureId
    ) {
        Map<String, Object> progress = buildMakerService.getStudentProgress(studentId, lectureId);
        return ResponseEntity.ok(progress);
    }

    @DeleteMapping("/lectures/{lectureId}")
    public ResponseEntity<Map<String, String>> deleteLecture(@PathVariable Long lectureId) {
        boolean deleted = buildMakerService.deleteLecture(lectureId);
        Map<String, String> response = new HashMap<>();
        response.put("message", deleted ? "강의가 삭제되었습니다" : "삭제 실패");
        return ResponseEntity.ok(response);
    }
}
