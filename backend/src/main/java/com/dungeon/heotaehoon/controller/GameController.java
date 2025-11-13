package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.dto.QuizAnswerRequest;
import com.dungeon.heotaehoon.dto.QuizAnswerResponse;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.StudentRepository;
import com.dungeon.heotaehoon.service.GameService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/game")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class GameController {

    private final GameService gameService;
    private final StudentRepository studentRepository;

    @GetMapping("/student/{username}")
    public ResponseEntity<Student> getStudent(@PathVariable String username) {
        return studentRepository.findByUsername(username)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/quiz/{quizId}/answer")
    public ResponseEntity<QuizAnswerResponse> submitAnswer(
            @PathVariable String quizId,
            @RequestBody QuizAnswerRequest request) {
        QuizAnswerResponse response = gameService.submitQuizAnswer(quizId, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/rage/random")
    public ResponseEntity<Map<String, String>> getRandomRage() {
        return ResponseEntity.ok(gameService.getRandomRageDialogue());
    }
}
