package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/ranking")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class RankingController {

    private final StudentRepository studentRepository;

    @GetMapping("/top")
    public ResponseEntity<List<Student>> getTopStudents() {
        List<Student> allStudents = studentRepository.findAll();

        List<Student> topStudents = allStudents.stream()
            .sorted((s1, s2) -> {
                int compare = Integer.compare(s2.getLevel(), s1.getLevel());
                if (compare == 0) {
                    compare = Integer.compare(s2.getExp(), s1.getExp());
                }
                if (compare == 0) {
                    compare = Integer.compare(s2.getTotalCorrect(), s1.getTotalCorrect());
                }
                return compare;
            })
            .limit(10)
            .collect(Collectors.toList());

        return ResponseEntity.ok(topStudents);
    }

    @GetMapping("/top10")
    public ResponseEntity<List<Map<String, Object>>> getTop10() {
        List<Student> allStudents = studentRepository.findAll();

        List<Map<String, Object>> rankings = allStudents.stream()
            .sorted((s1, s2) -> {
                int compare = Integer.compare(s2.getLevel(), s1.getLevel());
                if (compare == 0) {
                    compare = Integer.compare(s2.getExp(), s1.getExp());
                }
                if (compare == 0) {
                    compare = Integer.compare(s2.getTotalCorrect(), s1.getTotalCorrect());
                }
                return compare;
            })
            .limit(10)
            .map(student -> {
                Map<String, Object> rank = new HashMap<>();
                rank.put("id", student.getId());
                rank.put("displayName", student.getDisplayName());
                rank.put("level", student.getLevel());
                rank.put("exp", student.getExp());
                rank.put("totalCorrect", student.getTotalCorrect());
                rank.put("totalWrong", student.getTotalWrong());
                rank.put("characterExpression", student.getCharacterExpression());
                rank.put("characterOutfit", student.getCharacterOutfit());
                
                int total = student.getTotalCorrect() + student.getTotalWrong();
                double accuracy = total > 0 ? (student.getTotalCorrect() * 100.0 / total) : 0;
                rank.put("accuracy", String.format("%.1f%%", accuracy));
                
                return rank;
            })
            .collect(Collectors.toList());

        return ResponseEntity.ok(rankings);
    }
}
