package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Boss;
import com.dungeon.heotaehoon.repository.BossRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

    @PutMapping("/{id}/hp")
    public ResponseEntity<Map<String, Object>> updateBossHp(
            @PathVariable String id,
            @RequestBody Map<String, Integer> request) {
        Boss boss = bossRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("보스를 찾을 수 없습니다"));

        Integer damage = request.get("damage");
        if (damage != null) {
            int newHp = Math.max(0, boss.getCurrentHp() - damage);
            boss.setCurrentHp(newHp);

            if (newHp <= 0) {
                boss.setIsDefeated(true);
            }

            bossRepository.save(boss);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("boss", boss);
        result.put("isDefeated", boss.getIsDefeated());
        result.put("currentHp", boss.getCurrentHp());
        result.put("totalHp", boss.getTotalHp());

        return ResponseEntity.ok(result);
    }
}
