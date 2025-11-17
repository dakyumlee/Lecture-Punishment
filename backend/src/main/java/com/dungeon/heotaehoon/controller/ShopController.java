package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.ShopItem;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.ShopItemRepository;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/shop")
@RequiredArgsConstructor
public class ShopController {

    private final ShopItemRepository shopItemRepository;
    private final StudentRepository studentRepository;

    @GetMapping("/items")
    public ResponseEntity<List<ShopItem>> getAllItems() {
        List<ShopItem> items = shopItemRepository.findAll();
        if (items.isEmpty) {
            return ResponseEntity.ok(List.of());
        }
        return ResponseEntity.ok(items);
    }

    @GetMapping("/items/available")
    public ResponseEntity<List<ShopItem>> getAvailableItems() {
        return ResponseEntity.ok(shopItemRepository.findByIsAvailableTrue());
    }

    @GetMapping("/items/type/{type}")
    public ResponseEntity<List<ShopItem>> getItemsByType(@PathVariable String type) {
        return ResponseEntity.ok(shopItemRepository.findByItemType(type));
    }

    @PostMapping("/buy")
    public ResponseEntity<?> purchaseItem(@RequestBody Map<String, String> request) {
        try {
            String studentId = request.get("studentId");
            String itemId = request.get("itemId");

            Student student = studentRepository.findById(studentId)
                    .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

            ShopItem item = shopItemRepository.findById(itemId)
                    .orElseThrow(() -> new RuntimeException("아이템을 찾을 수 없습니다"));

            if (!item.getIsAvailable()) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "구매할 수 없는 아이템입니다"
                ));
            }

            if (student.getPoints() < item.getPrice()) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "포인트가 부족합니다"
                ));
            }

            student.setPoints(student.getPoints() - item.getPrice());
            
            if ("expression".equals(item.getItemType())) {
                student.setCharacterExpression(item.getImageUrl());
            } else if ("outfit".equals(item.getItemType())) {
                student.setCharacterOutfit(item.getImageUrl());
            }
            
            studentRepository.save(student);

            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "구매 완료",
                "remainingPoints", student.getPoints(),
                "student", student
            ));
            
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "구매 실패: " + e.getMessage()
            ));
        }
    }
}
