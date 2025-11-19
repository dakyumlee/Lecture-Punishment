package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CustomizationService {

    private final CustomizationItemRepository itemRepository;
    private final StudentCustomizationRepository customizationRepository;
    private final StudentRepository studentRepository;

    public Map<String, Object> getCustomization(String studentId) {
        List<StudentCustomization> owned = customizationRepository.findByStudentId(studentId);
        List<Long> ownedItemIds = owned.stream()
            .map(c -> c.getItem().getId())
            .collect(Collectors.toList());

        List<CustomizationItem> allItems = itemRepository.findAll();

        Map<String, Object> result = new HashMap<>();
        result.put("ownedItemIds", ownedItemIds);
        result.put("allItems", allItems);

        return result;
    }

    @Transactional
    public Map<String, Object> purchaseItem(String studentId, Long itemId) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

        CustomizationItem item = itemRepository.findById(itemId)
            .orElseThrow(() -> new RuntimeException("아이템을 찾을 수 없습니다"));

        Optional<StudentCustomization> existing = customizationRepository
            .findByStudentIdAndItemId(studentId, itemId);
        
        if (existing.isPresent()) {
            throw new RuntimeException("이미 소유한 아이템입니다");
        }

        if (student.getPoints() < item.getPrice()) {
            throw new RuntimeException("포인트가 부족합니다");
        }

        student.setPoints(student.getPoints() - item.getPrice());
        studentRepository.save(student);

        StudentCustomization customization = StudentCustomization.builder()
            .student(student)
            .item(item)
            .build();
        customizationRepository.save(customization);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("remainingPoints", student.getPoints());
        result.put("purchasedItem", item);

        return result;
    }

    @Transactional
    public Map<String, Object> applyCustomization(String studentId, Map<String, String> customization) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

        String expression = customization.get("expression");
        if (expression != null) {
            student.setCharacterExpression(expression);
        }

        studentRepository.save(student);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("appliedCustomization", customization);

        return result;
    }
}
