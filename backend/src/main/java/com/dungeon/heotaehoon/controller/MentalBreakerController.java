package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.service.MentalBreakerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/mental-breaker")
@RequiredArgsConstructor
public class MentalBreakerController {
    
    private final MentalBreakerService mentalBreakerService;
    
    @PostMapping("/process")
    public ResponseEntity<Map<String, Object>> processMentalBreak(
        @RequestBody Map<String, Object> request
    ) {
        String studentId = (String) request.get("studentId");
        Boolean isCorrect = (Boolean) request.get("isCorrect");
        
        Map<String, Object> result = mentalBreakerService.processMentalBreak(studentId, isCorrect);
        return ResponseEntity.ok(result);
    }
    
    @GetMapping("/state/{studentId}")
    public ResponseEntity<Map<String, Object>> getMentalState(@PathVariable String studentId) {
        Map<String, Object> state = mentalBreakerService.getMentalState(studentId);
        return ResponseEntity.ok(state);
    }
    
    @PostMapping("/recovery/complete")
    public ResponseEntity<Map<String, Object>> completeRecoveryMission(
        @RequestBody Map<String, Object> request
    ) {
        String studentId = (String) request.get("studentId");
        Integer recoveryAmount = (Integer) request.get("recoveryAmount");
        
        Map<String, Object> result = mentalBreakerService.completRecoveryMission(studentId, recoveryAmount);
        return ResponseEntity.ok(result);
    }
}
