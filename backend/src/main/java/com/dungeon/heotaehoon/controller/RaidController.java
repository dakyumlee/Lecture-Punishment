package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.RaidBoss;
import com.dungeon.heotaehoon.entity.RaidSession;
import com.dungeon.heotaehoon.service.RaidService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/raid")
@RequiredArgsConstructor
public class RaidController {

    private final RaidService raidService;

    @GetMapping("/bosses")
    public ResponseEntity<List<RaidBoss>> getActiveRaidBosses() {
        return ResponseEntity.ok(raidService.getActiveRaidBosses());
    }

    @GetMapping("/sessions")
    public ResponseEntity<List<RaidSession>> getActiveSessions() {
        return ResponseEntity.ok(raidService.getActiveRaidSessions());
    }

    @GetMapping("/sessions/{sessionId}")
    public ResponseEntity<Map<String, Object>> getSessionDetails(@PathVariable String sessionId) {
        return ResponseEntity.ok(raidService.getRaidSessionDetails(sessionId));
    }

    @PostMapping("/sessions")
    public ResponseEntity<Map<String, Object>> createSession(@RequestBody Map<String, String> request) {
        String raidBossId = request.get("raidBossId");
        String groupId = request.get("groupId");
        return ResponseEntity.ok(raidService.createRaidSession(raidBossId, groupId));
    }

    @PostMapping("/sessions/{sessionId}/join")
    public ResponseEntity<Map<String, Object>> joinSession(
            @PathVariable String sessionId,
            @RequestBody Map<String, String> request) {
        String studentId = request.get("studentId");
        return ResponseEntity.ok(raidService.joinRaidSession(sessionId, studentId));
    }

    @PostMapping("/sessions/{sessionId}/start")
    public ResponseEntity<Map<String, Object>> startSession(@PathVariable String sessionId) {
        return ResponseEntity.ok(raidService.startRaidSession(sessionId));
    }

    @PostMapping("/sessions/{sessionId}/damage")
    public ResponseEntity<Map<String, Object>> dealDamage(
            @PathVariable String sessionId,
            @RequestBody Map<String, Object> request) {
        String studentId = (String) request.get("studentId");
        Integer damage = (Integer) request.get("damage");
        return ResponseEntity.ok(raidService.dealDamage(sessionId, studentId, damage != null ? damage : 0));
    }

    @PostMapping("/sessions/{sessionId}/reward")
    public ResponseEntity<Map<String, Object>> claimReward(
            @PathVariable String sessionId,
            @RequestBody Map<String, String> request) {
        String studentId = request.get("studentId");
        return ResponseEntity.ok(raidService.claimReward(sessionId, studentId));
    }
}
