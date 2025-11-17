package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.MentalRecoveryMission;
import com.dungeon.heotaehoon.repository.MentalRecoveryMissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class MentalRecoveryService {
    
    private final MentalRecoveryMissionRepository missionRepository;
    private final StudentService studentService;
    private final Random random = new Random();

    public List<MentalRecoveryMission> getAllActiveMissions() {
        return missionRepository.findByIsActiveTrue();
    }

    public MentalRecoveryMission getRandomMission(String missionType) {
        List<MentalRecoveryMission> missions = missionRepository.findByMissionTypeAndIsActiveTrue(missionType);
        if (missions.isEmpty()) {
            throw new RuntimeException("사용 가능한 회복 미션이 없습니다");
        }
        return missions.get(random.nextInt(missions.size()));
    }

    public Map<String, Object> completeMission(String studentId, String missionId, String answer) {
        MentalRecoveryMission mission = missionRepository.findById(missionId)
                .orElseThrow(() -> new RuntimeException("미션을 찾을 수 없습니다"));

        boolean isCorrect = false;
        
        if ("word_quiz".equals(mission.getMissionType())) {
            isCorrect = checkAnswer(mission.getCorrectAnswer(), answer);
        } else if ("self_praise".equals(mission.getMissionType())) {
            isCorrect = answer != null && answer.length() >= 10;
        } else if ("meditation".equals(mission.getMissionType())) {
            isCorrect = true;
        }

        Map<String, Object> result = new HashMap<>();
        result.put("success", isCorrect);
        
        if (isCorrect) {
            Map<String, Object> recoveryResult = studentService.recoverMental(studentId, mission.getRecoveryAmount());
            result.putAll(recoveryResult);
            result.put("message", "멘탈 회복 성공! +" + mission.getRecoveryAmount());
        } else {
            result.put("message", "회복 실패... 다시 시도해보세요");
        }
        
        return result;
    }

    private boolean checkAnswer(String correct, String answer) {
        if (correct == null || answer == null) {
            return false;
        }
        return correct.trim().equalsIgnoreCase(answer.trim());
    }
}
