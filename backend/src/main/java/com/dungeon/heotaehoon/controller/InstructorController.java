package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Instructor;
import com.dungeon.heotaehoon.service.InstructorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/instructor")
@RequiredArgsConstructor
public class InstructorController {

    private final InstructorService instructorService;

    @GetMapping
    public ResponseEntity<Instructor> getInstructor() {
        return ResponseEntity.ok(instructorService.getInstructor());
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getInstructorStats() {
        return ResponseEntity.ok(instructorService.getInstructorStats());
    }

    @PostMapping("/exp")
    public ResponseEntity<Map<String, Object>> addInstructorExp(@RequestBody Map<String, Object> request) {
        String instructorId = (String) request.getOrDefault("instructorId", "default-instructor");
        Integer exp = (Integer) request.getOrDefault("exp", 5);
        
        Map<String, Object> result = instructorService.addInstructorExp(instructorId, exp);
        
        return ResponseEntity.ok(result);
    }

    @PostMapping("/rage/add")
    public ResponseEntity<Instructor> addRage(@RequestBody Map<String, Integer> request) {
        Integer rageAmount = request.get("rage");
        Instructor instructor = instructorService.addRage(rageAmount != null ? rageAmount : 5);
        return ResponseEntity.ok(instructor);
    }

    @PostMapping("/rage/reduce")
    public ResponseEntity<Instructor> reduceRage(@RequestBody Map<String, Integer> request) {
        Integer rageAmount = request.get("rage");
        Instructor instructor = instructorService.reduceRage(rageAmount != null ? rageAmount : 5);
        return ResponseEntity.ok(instructor);
    }

    @PostMapping("/evolve")
    public ResponseEntity<Instructor> evolveToFather() {
        Instructor instructor = instructorService.evolveToFather();
        return ResponseEntity.ok(instructor);
    }
    @GetMapping("/evolution/check")
    public ResponseEntity<Map<String, Object>> checkEvolution() {
        Map<String, Object> condition = instructorService.checkEvolutionCondition();
        return ResponseEntity.ok(condition);
    }

    @PostMapping("/evolution/auto")
    public ResponseEntity<Map<String, Object>> autoEvolve() {
        Map<String, Object> result = instructorService.tryAutoEvolve();
        return ResponseEntity.ok(result);
    }

}
