package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.MentalRecoveryMission;
import com.dungeon.heotaehoon.service.MentalRecoveryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/mental-recovery")
@RequiredArgsConstructor
public class MentalRecoveryController {

    private final MentalRecoveryService mentalRecoveryService;

    @GetMapping("/missions")
    public ResponseEntity<List<MentalRecoveryMission>> getAllMissions() {
        return ResponseEntity.ok(mentalRecoveryService.getAllActiveMissions());
    }

    @GetMapping("/missions/random/{type}")
    public ResponseEntity<MentalRecoveryMission> getRandomMission(@PathVariable String type) {
        return ResponseEntity.ok(mentalRecoveryService.getRandomMission(type));
    }

    @PostMapping("/complete")
    public ResponseEntity<Map<String, Object>> completeMission(@RequestBody Map<String, String> request) {
        String studentId = request.get("studentId");
        String missionId = request.get("missionId");
        String answer = request.get("answer");
        
        Map<String, Object> result = mentalRecoveryService.completeMission(studentId, missionId, answer);
        return ResponseEntity.ok(result);
    }
}
