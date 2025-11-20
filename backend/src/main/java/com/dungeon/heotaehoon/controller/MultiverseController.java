package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.service.MultiverseService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/multiverse")
@RequiredArgsConstructor
public class MultiverseController {

    private final MultiverseService multiverseService;

    @GetMapping("/universes/{studentId}")
    public ResponseEntity<List<Map<String, Object>>> getAvailableUniverses(@PathVariable String studentId) {
        return ResponseEntity.ok(multiverseService.getAvailableUniverses(studentId));
    }

    @PostMapping("/fragment/obtain")
    public ResponseEntity<Map<String, Object>> obtainSoulFragment(@RequestBody Map<String, String> request) {
        String studentId = request.get("studentId");
        String multiverseInstructorId = request.get("multiverseInstructorId");
        return ResponseEntity.ok(multiverseService.obtainSoulFragment(studentId, multiverseInstructorId));
    }

    @GetMapping("/progress/{studentId}")
    public ResponseEntity<Map<String, Object>> getStudentProgress(@PathVariable String studentId) {
        return ResponseEntity.ok(multiverseService.getStudentProgress(studentId));
    }

    @PostMapping("/ending/unlock")
    public ResponseEntity<Map<String, Object>> unlockSpecialEnding(@RequestBody Map<String, String> request) {
        String studentId = request.get("studentId");
        return ResponseEntity.ok(multiverseService.unlockSpecialEnding(studentId));
    }
}
