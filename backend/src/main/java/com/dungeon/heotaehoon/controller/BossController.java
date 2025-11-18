package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Boss;
import com.dungeon.heotaehoon.repository.BossRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
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
    public ResponseEntity<Map<String, Object>> getBossById(@PathVariable String id) {
        try {
            Boss boss = bossRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("보스를 찾을 수 없습니다"));
            
            Map<String, Object> response = new HashMap<>();
            response.put("id", boss.getId());
            response.put("bossName", boss.getName());
            response.put("bossSubtitle", boss.getBossSubtitle() != null ? boss.getBossSubtitle() : "지식의 수호자");
            response.put("difficulty", boss.getDifficulty() != null ? boss.getDifficulty() : 3);
            response.put("difficultyStars", boss.getDifficultyStars());
            response.put("specialAbility", boss.getSpecialAbility() != null ? boss.getSpecialAbility() : "없음");
            response.put("totalHp", boss.getTotalHp() != null ? boss.getTotalHp() : 1000);
            response.put("currentHp", boss.getCurrentHp() != null ? boss.getCurrentHp() : 1000);
            response.put("damagePerCorrect", boss.getDamagePerCorrect() != null ? boss.getDamagePerCorrect() : 200);
            response.put("isDefeated", boss.getIsDefeated() != null ? boss.getIsDefeated() : false);
            response.put("defeatRewardExp", boss.getDefeatRewardExp() != null ? boss.getDefeatRewardExp() : 30);
            response.put("defeatRewardPoints", boss.getDefeatRewardPoints() != null ? boss.getDefeatRewardPoints() : 150);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to get boss: {}", id, e);
            return ResponseEntity.status(500).body(new HashMap<>());
        }
    }

    @GetMapping("/lesson/{lessonId}")
    public ResponseEntity<List<Boss>> getBossesByLesson(@PathVariable String lessonId) {
        return ResponseEntity.ok(bossRepository.findByLessonId(lessonId));
    }

    @PutMapping("/{id}/hp")
    public ResponseEntity<Map<String, Object>> updateBossHp(
            @PathVariable String id,
            @RequestBody Map<String, Integer> request) {
        try {
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
        } catch (Exception e) {
            log.error("Failed to update boss HP: {}", id, e);
            return ResponseEntity.status(500).body(new HashMap<>());
        }
    }
}
