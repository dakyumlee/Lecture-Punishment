package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Instructor;
import com.dungeon.heotaehoon.repository.InstructorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class InstructorService {
    
    private final InstructorRepository instructorRepository;

    public Instructor getInstructor() {
        return instructorRepository.findByUsername("hth422")
                .orElseThrow(() -> new RuntimeException("허태훈 강사를 찾을 수 없습니다"));
    }

    @Transactional
    public Map<String, Object> addInstructorExp(String instructorId, int expAmount) {
        Instructor instructor = instructorRepository.findById(instructorId)
                .orElseGet(() -> getInstructor());
        
        int oldLevel = instructor.getLevel();
        int oldExp = instructor.getExp();
        int newExp = oldExp + expAmount;
        
        int expForNextLevel = oldLevel * 100;
        boolean leveledUp = false;
        int newLevel = oldLevel;
        
        while (newExp >= expForNextLevel) {
            newExp -= expForNextLevel;
            newLevel++;
            expForNextLevel = newLevel * 100;
            leveledUp = true;
        }
        
        instructor.setExp(newExp);
        instructor.setLevel(newLevel);
        
        if (leveledUp) {
            instructor.setCurrentTitle(getTitleForLevel(newLevel));
            instructor.setRageGauge(Math.max(0, instructor.getRageGauge() - 10));
        }
        
        instructorRepository.save(instructor);
        
        Map<String, Object> result = new HashMap<>();
        result.put("instructor", instructor);
        result.put("leveledUp", leveledUp);
        result.put("oldLevel", oldLevel);
        result.put("newLevel", newLevel);
        result.put("expGained", expAmount);
        
        return result;
    }

    @Transactional
    public Instructor addRage(int rageAmount) {
        Instructor instructor = getInstructor();
        
        int newRage = Math.min(100, instructor.getRageGauge() + rageAmount);
        instructor.setRageGauge(newRage);
        
        if (newRage >= 100 && !instructor.getIsEvolved()) {
            instructor.setEvolutionStage("enraged");
        }
        
        return instructorRepository.save(instructor);
    }

    @Transactional
    public Instructor reduceRage(int rageAmount) {
        Instructor instructor = getInstructor();
        
        int newRage = Math.max(0, instructor.getRageGauge() - rageAmount);
        instructor.setRageGauge(newRage);
        
        if (newRage < 50 && "enraged".equals(instructor.getEvolutionStage())) {
            instructor.setEvolutionStage("normal");
        }
        
        return instructorRepository.save(instructor);
    }

    @Transactional
    public Instructor evolveToFather() {
        Instructor instructor = getInstructor();
        
        instructor.setIsEvolved(true);
        instructor.setEvolutionStage("father");
        instructor.setRageGauge(0);
        
        return instructorRepository.save(instructor);
    }

    public Map<String, Object> getInstructorStats() {
        Instructor instructor = getInstructor();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("id", instructor.getId());
        stats.put("name", instructor.getName());
        stats.put("level", instructor.getLevel());
        stats.put("exp", instructor.getExp());
        stats.put("rageGauge", instructor.getRageGauge());
        stats.put("isEvolved", instructor.getIsEvolved());
        stats.put("evolutionStage", instructor.getEvolutionStage());
        stats.put("totalStudents", 0);
        stats.put("averageCorrectRate", 0);
        stats.put("totalQuizzes", 0);
        
        String statusMessage = getStatusMessage(instructor);
        stats.put("statusMessage", statusMessage);
        
        return stats;
    }

    private String getStatusMessage(Instructor instructor) {
        if (instructor.getIsEvolved()) {
            return "아빠 허태훈 — 더 이상 분노하지 않습니다";
        }
        
        int rage = instructor.getRageGauge();
        
        if (rage >= 80) {
            return "분노 폭발 직전";
        } else if (rage >= 60) {
            return "분노 게이지 상승 중";
        } else if (rage >= 40) {
            return "약간 짜증남";
        } else if (rage >= 20) {
            return "분노 게이지 안정화됨";
        } else {
            return "평온한 상태";
        }
    }
    
    private String getTitleForLevel(int level) {
        if (level >= 10) return "Lv." + level + " — 아빠 허태훈 (부성애 각성)";
        if (level >= 7) return "Lv." + level + " — 분노 게이지 안정화됨";
        if (level >= 5) return "Lv." + level + " — 독설의 달인";
        if (level >= 3) return "Lv." + level + " — 엄격한 교육자";
        return "Lv." + level + " — 신입 강사";
    }
}
