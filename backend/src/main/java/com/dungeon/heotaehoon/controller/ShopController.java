package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.ShopItem;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.ShopItemRepository;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/shop")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ShopController {

    private final ShopItemRepository shopItemRepository;
    private final StudentRepository studentRepository;

    @GetMapping("/items")
    public ResponseEntity<List<ShopItem>> getAllItems() {
        return ResponseEntity.ok(shopItemRepository.findAll());
    }

    @GetMapping("/items/available")
    public ResponseEntity<List<ShopItem>> getAvailableItems() {
        return ResponseEntity.ok(shopItemRepository.findByIsAvailableTrue());
    }

    @GetMapping("/items/category/{category}")
    public ResponseEntity<List<ShopItem>> getItemsByCategory(@PathVariable String category) {
        return ResponseEntity.ok(shopItemRepository.findByCategory(category));
    }

    @PostMapping("/purchase")
    public ResponseEntity<?> purchaseItem(@RequestBody Map<String, String> request) {
        try {
            String studentId = request.get("studentId");
            String itemId = request.get("itemId");

            Student student = studentRepository.findById(studentId)
                    .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

            ShopItem item = shopItemRepository.findById(itemId)
                    .orElseThrow(() -> new RuntimeException("아이템을 찾을 수 없습니다"));

            if (!item.getIsAvailable()) {
                return ResponseEntity.badRequest().body(Map.of("error", "구매할 수 없는 아이템입니다"));
            }

            if (student.getPoints() < item.getPrice()) {
                return ResponseEntity.badRequest().body(Map.of("error", "포인트가 부족합니다"));
            }

            student.setPoints(student.getPoints() - item.getPrice());

            if ("expression".equals(item.getCategory())) {
                student.setCharacterExpression(item.getItemCode());
            } else if ("outfit".equals(item.getCategory())) {
                student.setCharacterOutfit(item.getItemCode());
            }

            studentRepository.save(student);

            return ResponseEntity.ok(Map.of(
                    "message", "구매 완료",
                    "remainingPoints", student.getPoints()
            ));

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/equip")
    public ResponseEntity<?> equipItem(@RequestBody Map<String, String> request) {
        try {
            String studentId = request.get("studentId");
            String itemId = request.get("itemId");

            Student student = studentRepository.findById(studentId)
                    .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

            ShopItem item = shopItemRepository.findById(itemId)
                    .orElseThrow(() -> new RuntimeException("아이템을 찾을 수 없습니다"));

            if ("expression".equals(item.getCategory())) {
                student.setCharacterExpression(item.getItemCode());
            } else if ("outfit".equals(item.getCategory())) {
                student.setCharacterOutfit(item.getItemCode());
            }

            studentRepository.save(student);

            return ResponseEntity.ok(Map.of("message", "장착 완료"));

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }
}
