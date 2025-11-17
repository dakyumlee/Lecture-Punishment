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
    public Map<String, Object> addInstructorExp(int expAmount) {
        Instructor instructor = getInstructor();
        
        int oldLevel = instructor.getLevel();
        int oldExp = instructor.getExp();
        
        instructor.setExp(oldExp + expAmount);
        
        int newLevel = oldLevel;
        boolean leveledUp = false;
        
        while (instructor.getExp() >= 100) {
            instructor.setExp(instructor.getExp() - 100);
            newLevel++;
            leveledUp = true;
            
            instructor.setRageGauge(Math.max(0, instructor.getRageGauge() - 10));
        }
        
        if (leveledUp) {
            instructor.setLevel(newLevel);
        }
        
        instructorRepository.save(instructor);
        
        Map<String, Object> result = new HashMap<>();
        result.put("instructor", instructor);
        result.put("leveledUp", leveledUp);
        result.put("oldLevel", oldLevel);
        result.put("newLevel", newLevel);
        result.put("expGained", expAmount);
        result.put("rageReduced", leveledUp);
        
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
}
