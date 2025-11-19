package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.service.CustomizationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/student/customization")
@RequiredArgsConstructor
public class CustomizationController {

    private final CustomizationService customizationService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getCustomization(@RequestParam String studentId) {
        try {
            Map<String, Object> result = customizationService.getCustomization(studentId);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/purchase")
    public ResponseEntity<Map<String, Object>> purchaseItem(@RequestBody Map<String, Object> request) {
        try {
            String studentId = (String) request.get("studentId");
            Long itemId = Long.valueOf(request.get("itemId").toString());

            Map<String, Object> result = customizationService.purchaseItem(studentId, itemId);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/apply")
    public ResponseEntity<Map<String, Object>> applyCustomization(@RequestBody Map<String, Object> request) {
        try {
            String studentId = (String) request.get("studentId");
            @SuppressWarnings("unchecked")
            Map<String, String> customization = (Map<String, String>) request.get("customization");

            Map<String, Object> result = customizationService.applyCustomization(studentId, customization);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
