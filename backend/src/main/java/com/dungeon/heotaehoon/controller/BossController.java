package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Boss;
import com.dungeon.heotaehoon.repository.BossRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bosses")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class BossController {

    private final BossRepository bossRepository;

    @GetMapping
    public ResponseEntity<List<Boss>> getAllBosses() {
        return ResponseEntity.ok(bossRepository.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Boss> getBossById(@PathVariable String id) {
        return bossRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/lesson/{lessonId}")
    public ResponseEntity<List<Boss>> getBossesByLesson(@PathVariable String lessonId) {
        return ResponseEntity.ok(bossRepository.findByLessonId(lessonId));
    }
}