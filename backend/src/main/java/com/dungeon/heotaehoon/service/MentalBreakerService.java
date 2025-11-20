package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class MentalBreakerService {
    
    private final MentalStateRepository mentalStateRepository;
    private final StudentRepository studentRepository;
    private final OpenAIService openAIService;
    
    @Transactional
    public Map<String, Object> processMentalBreak(String studentId, boolean isCorrect) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
        
        MentalState mentalState = mentalStateRepository.findByStudent(student)
            .orElseGet(() -> createInitialMentalState(student));
        
        if (isCorrect) {
            return handleCorrectAnswer(mentalState);
        } else {
            return handleWrongAnswer(mentalState);
        }
    }
    
    private MentalState createInitialMentalState(Student student) {
        MentalState mentalState = MentalState.builder()
            .student(student)
            .mentalGauge(100)
            .consecutiveWrongs(0)
            .consecutiveCorrects(0)
            .currentMood("보통")
            .isInCrisis(false)
            .totalBreakdowns(0)
            .totalRecoveries(0)
            .build();
        return mentalStateRepository.save(mentalState);
    }
    
    private Map<String, Object> handleCorrectAnswer(MentalState mentalState) {
        mentalState.setConsecutiveCorrects(mentalState.getConsecutiveCorrects() + 1);
        mentalState.setConsecutiveWrongs(0);
        
        int recovery = Math.min(10, 100 - mentalState.getMentalGauge());
        mentalState.setMentalGauge(mentalState.getMentalGauge() + recovery);
        
        if (mentalState.getMentalGauge() > 70) {
            mentalState.setCurrentMood("안정");
            mentalState.setIsInCrisis(false);
        } else if (mentalState.getMentalGauge() > 40) {
            mentalState.setCurrentMood("보통");
        }
        
        mentalStateRepository.save(mentalState);
        
        Map<String, Object> response = new HashMap<>();
        response.put("mentalGauge", mentalState.getMentalGauge());
        response.put("mood", mentalState.getCurrentMood());
        response.put("isInCrisis", mentalState.getIsInCrisis());
        response.put("message", "정답! 멘탈 회복 +" + recovery);
        return response;
    }
    
    private Map<String, Object> handleWrongAnswer(MentalState mentalState) {
        mentalState.setConsecutiveWrongs(mentalState.getConsecutiveWrongs() + 1);
        mentalState.setConsecutiveCorrects(0);
        
        int damage = calculateMentalDamage(mentalState.getConsecutiveWrongs());
        mentalState.setMentalGauge(Math.max(0, mentalState.getMentalGauge() - damage));
        
        String dialogueType;
        boolean triggerBreaker = false;
        
        if (mentalState.getMentalGauge() <= 20) {
            mentalState.setCurrentMood("멘탈붕괴");
            mentalState.setIsInCrisis(true);
            mentalState.setTotalBreakdowns(mentalState.getTotalBreakdowns() + 1);
            mentalState.setLastBreakerTime(LocalDateTime.now());
            dialogueType = "destruction";
            triggerBreaker = true;
        } else if (mentalState.getMentalGauge() <= 40) {
            mentalState.setCurrentMood("위기");
            dialogueType = "pressure";
        } else if (mentalState.getMentalGauge() <= 70) {
            mentalState.setCurrentMood("불안");
            dialogueType = "doubt";
        } else {
            mentalState.setCurrentMood("보통");
            dialogueType = "light";
        }
        
        mentalStateRepository.save(mentalState);
        
        String breakerMessage = generateAIDialogue(dialogueType, mentalState.getMentalGauge(), mentalState.getConsecutiveWrongs());
        
        Map<String, Object> response = new HashMap<>();
        response.put("mentalGauge", mentalState.getMentalGauge());
        response.put("mood", mentalState.getCurrentMood());
        response.put("isInCrisis", mentalState.getIsInCrisis());
        response.put("damage", damage);
        response.put("message", breakerMessage);
        response.put("triggerRecoveryMission", triggerBreaker);
        response.put("consecutiveWrongs", mentalState.getConsecutiveWrongs());
        
        return response;
    }
    
    private int calculateMentalDamage(int consecutiveWrongs) {
        if (consecutiveWrongs >= 5) return 25;
        if (consecutiveWrongs >= 3) return 15;
        return 10;
    }
    
    private String generateAIDialogue(String dialogueType, int mentalGauge, int consecutiveWrongs) {
        String mood = getMoodDescription(mentalGauge);
        String intensity = getIntensityDescription(consecutiveWrongs);
        
        String prompt = String.format(
            "너는 '허태훈' 강사야. 학생이 문제를 틀렸어. 학생의 멘탈을 공격하는 한 문장을 만들어줘.\n\n" +
            "상황:\n" +
            "- 현재 학생 멘탈 게이지: %d/100 (%s)\n" +
            "- 연속 오답 횟수: %d회 (%s)\n" +
            "- 대사 유형: %s\n\n" +
            "조건:\n" +
            "- 반말 사용\n" +
            "- 냉소적이고 날카로운 톤\n" +
            "- 한 문장으로 끝낼 것\n" +
            "- 학생의 자존감을 건드릴 것\n" +
            "- %s\n\n" +
            "대사만 출력해:",
            mentalGauge, mood, consecutiveWrongs, intensity, dialogueType, getDialogueGuideline(dialogueType)
        );
        
        try {
            return openAIService.generateText(prompt, 150);
        } catch (Exception e) {
            return getDefaultDialogue(dialogueType);
        }
    }
    
    private String getMoodDescription(int mentalGauge) {
        if (mentalGauge <= 20) return "멘탈붕괴";
        if (mentalGauge <= 40) return "위기 상태";
        if (mentalGauge <= 70) return "불안 상태";
        return "보통";
    }
    
    private String getIntensityDescription(int consecutiveWrongs) {
        if (consecutiveWrongs >= 5) return "매우 심각";
        if (consecutiveWrongs >= 3) return "위험 수준";
        return "경고 단계";
    }
    
    private String getDialogueGuideline(String dialogueType) {
        return switch (dialogueType) {
            case "destruction" -> "학생이 포기하고 싶게 만드는 파괴적인 말. 재능 없다고 말하기";
            case "pressure" -> "다른 사람과 비교하며 압박하는 말. 시간 낭비라고 말하기";
            case "doubt" -> "학생의 능력을 의심하는 말. 복습 안 했다고 의심하기";
            case "light" -> "가볍게 꼬집는 말. 집중력 부족하다고 지적하기";
            default -> "학생을 자극하는 말";
        };
    }
    
    private String getDefaultDialogue(String dialogueType) {
        return switch (dialogueType) {
            case "destruction" -> "아니야 네가 못한 게 아니라 세상이 널 버린 거야";
            case "pressure" -> "이 정도 문제도 못 푸는데 어떻게 살아갈 거니?";
            case "doubt" -> "너는 복습을 했니? 했으면 이럴 리가 없지 ㅋㅋ";
            case "light" -> "또 틀렸네? 집중력이 문제인가?";
            default -> "다시 생각해봐";
        };
    }
    
    @Transactional(readOnly = true)
    public Map<String, Object> getMentalState(String studentId) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
        
        MentalState mentalState = mentalStateRepository.findByStudent(student)
            .orElseGet(() -> createInitialMentalState(student));
        
        Map<String, Object> response = new HashMap<>();
        response.put("mentalGauge", mentalState.getMentalGauge());
        response.put("mood", mentalState.getCurrentMood());
        response.put("isInCrisis", mentalState.getIsInCrisis());
        response.put("consecutiveWrongs", mentalState.getConsecutiveWrongs());
        response.put("consecutiveCorrects", mentalState.getConsecutiveCorrects());
        response.put("totalBreakdowns", mentalState.getTotalBreakdowns());
        response.put("totalRecoveries", mentalState.getTotalRecoveries());
        
        return response;
    }
    
    @Transactional
    public Map<String, Object> completeRecoveryMission(String studentId, int recoveryAmount) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
        
        MentalState mentalState = mentalStateRepository.findByStudent(student)
            .orElseThrow(() -> new RuntimeException("멘탈 상태를 찾을 수 없습니다"));
        
        mentalState.setMentalGauge(Math.min(100, mentalState.getMentalGauge() + recoveryAmount));
        mentalState.setTotalRecoveries(mentalState.getTotalRecoveries() + 1);
        mentalState.setConsecutiveWrongs(0);
        
        if (mentalState.getMentalGauge() > 20) {
            mentalState.setIsInCrisis(false);
            mentalState.setCurrentMood("회복");
        }
        
        mentalStateRepository.save(mentalState);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("mentalGauge", mentalState.getMentalGauge());
        response.put("recovered", recoveryAmount);
        response.put("message", "멘탈 회복 성공!");
        
        return response;
    }
}
