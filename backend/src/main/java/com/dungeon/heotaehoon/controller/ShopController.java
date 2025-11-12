package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.ShopItem;
import com.dungeon.heotaehoon.repository.StudentRepository;
import com.dungeon.heotaehoon.repository.ShopItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/shop")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ShopController {

    private final StudentRepository studentRepository;
    private final ShopItemRepository shopItemRepository;

    @GetMapping("/items")
    public ResponseEntity<Map<String, Object>> getShopItems(@RequestParam(required = false) String type) {
        List<ShopItem> items;
        
        if (type != null && !type.isEmpty()) {
            items = shopItemRepository.findByItemTypeAndIsAvailableTrue(type);
        } else {
            items = shopItemRepository.findByIsAvailableTrue();
        }
        
        Map<String, List<ShopItem>> groupedItems = items.stream()
            .collect(Collectors.groupingBy(ShopItem::getItemType));
        
        Map<String, Object> response = new HashMap<>();
        response.put("items", items);
        response.put("groupedItems", groupedItems);
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/buy")
    public ResponseEntity<Map<String, Object>> buyItem(@RequestBody Map<String, String> request) {
        String studentId = request.get("studentId");
        String itemId = request.get("itemId");

        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("Student not found"));

        ShopItem item = shopItemRepository.findById(itemId)
            .orElseThrow(() -> new RuntimeException("Item not found"));

        if (!item.getIsAvailable()) {
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "구매할 수 없는 아이템입니다"));
        }

        if (student.getPoints() < item.getPrice()) {
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "포인트가 부족합니다"));
        }

        student.setPoints(student.getPoints() - item.getPrice());

        if ("expression".equals(item.getItemType())) {
            student.setCharacterExpression(item.getName());
        } else if ("outfit".equals(item.getItemType())) {
            student.setCharacterOutfit(item.getName());
        }

        studentRepository.save(student);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "구매 완료!");
        response.put("item", item);
        response.put("remainingPoints", student.getPoints());
        response.put("student", student);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/student/{studentId}")
    public ResponseEntity<Map<String, Object>> getStudentInventory(@PathVariable String studentId) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("Student not found"));

        Map<String, Object> inventory = new HashMap<>();
        inventory.put("points", student.getPoints());
        inventory.put("currentOutfit", student.getCharacterOutfit());
        inventory.put("currentExpression", student.getCharacterExpression());

        return ResponseEntity.ok(inventory);
    }
}
