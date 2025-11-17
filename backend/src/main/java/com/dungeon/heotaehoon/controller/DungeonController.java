package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/api/dungeons")
@RequiredArgsConstructor
public class DungeonController {

    private final StudentRepository studentRepository;
    private final LessonRepository lessonRepository;
    private final BossRepository bossRepository;
    private final RageDialogueRepository rageDialogueRepository;

    @GetMapping("/student/{studentId}")
    public ResponseEntity<List<Map<String, Object>>> getAvailableDungeons(@PathVariable String studentId) {
        try {
            Student student = studentRepository.findById(studentId)
                    .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
            
            List<Lesson> lessons;
            if (student.getGroup() != null) {
                lessons = lessonRepository.findByGroupAndIsActiveTrue(student.getGroup());
            } else {
                lessons = lessonRepository.findByGroupIsNullAndIsActiveTrue();
            }
            
            List<Map<String, Object>> dungeons = new ArrayList<>();
            for (Lesson lesson : lessons) {
                Boss boss = bossRepository.findByLessonId(lesson.getId()).stream().findFirst().orElse(null);
                
                Map<String, Object> dungeon = new HashMap<>();
                dungeon.put("lessonId", lesson.getId());
                dungeon.put("title", lesson.getTitle());
                dungeon.put("subject", lesson.getSubject());
                dungeon.put("difficultyStars", lesson.getDifficultyStars());
                dungeon.put("lessonDate", lesson.getLessonDate());
                
                if (boss != null) {
                    dungeon.put("bossId", boss.getId());
                    dungeon.put("bossName", boss.getBossName());
                    dungeon.put("bossSubtitle", boss.getBossSubtitle());
                    dungeon.put("totalHp", boss.getTotalHp());
                    dungeon.put("currentHp", boss.getCurrentHp());
                    dungeon.put("isDefeated", boss.getIsDefeated());
                } else {
                    dungeon.put("bossId", null);
                    dungeon.put("bossName", "오늘의 보스: " + lesson.getSubject());
                    dungeon.put("bossSubtitle", "지식의 수호자");
                    dungeon.put("totalHp", 1000);
                    dungeon.put("currentHp", 1000);
                    dungeon.put("isDefeated", false);
                }
                
                dungeons.add(dungeon);
            }
            
            log.info("Found {} dungeons for student {}", dungeons.size(), studentId);
            return ResponseEntity.ok(dungeons);
        } catch (Exception e) {
            log.error("Failed to get dungeons", e);
            return ResponseEntity.status(500).body(new ArrayList<>());
        }
    }

    @GetMapping("/lesson/{lessonId}/entrance")
    public ResponseEntity<Map<String, Object>> getDungeonEntrance(@PathVariable String lessonId) {
        try {
            Lesson lesson = lessonRepository.findById(lessonId)
                    .orElseThrow(() -> new RuntimeException("수업을 찾을 수 없습니다"));
            
            Boss boss = bossRepository.findByLessonId(lessonId).stream().findFirst().orElse(null);
            
            String entranceDialogue = getRandomEntranceDialogue();
            
            Map<String, Object> entrance = new HashMap<>();
            entrance.put("lessonId", lesson.getId());
            entrance.put("title", lesson.getTitle());
            entrance.put("subject", lesson.getSubject());
            entrance.put("difficultyStars", lesson.getDifficultyStars());
            
            if (boss != null) {
                entrance.put("bossId", boss.getId());
                entrance.put("bossName", boss.getBossName());
                entrance.put("bossSubtitle", boss.getBossSubtitle());
                entrance.put("totalHp", boss.getTotalHp());
                entrance.put("currentHp", boss.getCurrentHp());
            } else {
                entrance.put("bossName", "오늘의 보스: " + lesson.getSubject());
                entrance.put("bossSubtitle", "지식의 수호자");
                entrance.put("totalHp", 1000);
                entrance.put("currentHp", 1000);
            }
            
            entrance.put("entranceDialogue", entranceDialogue);
            entrance.put("instructorName", "허태훈");
            
            return ResponseEntity.ok(entrance);
        } catch (Exception e) {
            log.error("Failed to get dungeon entrance", e);
            return ResponseEntity.status(500).body(new HashMap<>());
        }
    }

    @GetMapping("/rage/random")
    public ResponseEntity<Map<String, String>> getRandomRage() {
        try {
            List<String> rageMessages = Arrays.asList(
                "너는 복습을 했니? 했으면 이럴 리가 없지 ㅋㅋ",
                "목졸라뿐다",
                "니대가리로 이해가 가긴 하겠니",
                "이 정도도 못 풀면 뭐하러 왔어?",
                "아니 그걸 틀려? 진짜?",
                "다시 한 번 생각해봐... 아니다, 생각 자체를 안 하는구나",
                "야 그건 기본이잖아!",
                "이게 안 되면 앞으로 어쩌려고?",
                "복습 좀 해라, 제발"
            );
            
            Random random = new Random();
            String message = rageMessages.get(random.nextInt(rageMessages.size()));
            
            Map<String, String> response = new HashMap<>();
            response.put("message", message);
            response.put("type", "rage");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to get random rage", e);
            return ResponseEntity.status(500).body(new HashMap<>());
        }
    }

    private String getRandomEntranceDialogue() {
        List<String> dialogues = Arrays.asList(
            "안 외웠으면 뒤진다",
            "오늘은 누가 멘탈 나갈까?",
            "준비됐어? 안 됐어도 들어와",
            "복습 안 한 놈 손들어봐... 아 다들 안 했구나",
            "이번엔 쉽게 안 넘어간다",
            "집중해. 한 문제만 틀려도 분노 게이지 차오른다",
            "자, 시작하자. 멘탈 단단히 붙들어",
            "오늘 수업 내용 기억나? 안 나면 각오해"
        );
        
        Random random = new Random();
        return dialogues.get(random.nextInt(dialogues.size()));
    }
}
