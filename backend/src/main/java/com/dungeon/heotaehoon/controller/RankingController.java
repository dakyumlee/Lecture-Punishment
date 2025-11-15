package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/ranking")
@RequiredArgsConstructor
public class RankingController {

    private final StudentRepository studentRepository;

    @GetMapping
    public ResponseEntity<List<Student>> getRanking() {
        List<Student> students = studentRepository.findAll()
                .stream()
                .sorted((s1, s2) -> Integer.compare(s2.getLevel(), s1.getLevel()))
                .limit(100)
                .collect(Collectors.toList());
        return ResponseEntity.ok(students);
    }
}
