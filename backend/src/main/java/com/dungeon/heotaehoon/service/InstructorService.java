package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Instructor;
import com.dungeon.heotaehoon.repository.InstructorRepository;
import com.dungeon.heotaehoon.repository.StudentRepository;
import com.dungeon.heotaehoon.repository.RageDialogueRepository;
import com.dungeon.heotaehoon.repository.StudentSubmissionRepository;
import com.dungeon.heotaehoon.entity.RageDialogue;
import com.dungeon.heotaehoon.entity.StudentSubmission;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import com.dungeon.heotaehoon.entity.Student;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class InstructorService {
    
    private final InstructorRepository instructorRepository;
    private final StudentRepository studentRepository;
    private final RageDialogueRepository rageDialogueRepository;
    private final StudentSubmissionRepository submissionRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public Instructor getInstructor() {
        return instructorRepository.findByUsername("hth422")
                .orElseGet(() -> createDefaultInstructor());
    }

    private Instructor createDefaultInstructor() {
        Instructor instructor = Instructor.builder()
                .username("hth422")
                .password(passwordEncoder.encode("hth422"))
                .name("허태훈")
                .level(1)
                .exp(0)
                .currentTitle("Lv.1 — 신입 강사")
                .rageGauge(0)
                .isEvolved(false)
                .evolutionStage("normal")
                .build();
        
        return instructorRepository.save(instructor);
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
        
        List<Student> allStudents = studentRepository.findAll();
        List<StudentSubmission> allSubmissions = submissionRepository.findAll();
        
        long totalCorrect = allStudents.stream()
            .mapToLong(s -> s.getTotalCorrect() != null ? s.getTotalCorrect() : 0)
            .sum();
        long totalWrong = allStudents.stream()
            .mapToLong(s -> s.getTotalWrong() != null ? s.getTotalWrong() : 0)
            .sum();
        
        double averageCorrectRate = totalCorrect + totalWrong > 0 
            ? (double) totalCorrect / (totalCorrect + totalWrong) * 100 
            : 0;
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("id", instructor.getId());
        stats.put("name", instructor.getName());
        stats.put("level", instructor.getLevel());
        stats.put("exp", instructor.getExp());
        stats.put("rageGauge", instructor.getRageGauge());
        stats.put("isEvolved", instructor.getIsEvolved());
        stats.put("evolutionStage", instructor.getEvolutionStage());
        stats.put("currentTitle", instructor.getCurrentTitle());
        stats.put("totalStudents", allStudents.size());
        stats.put("averageCorrectRate", Math.round(averageCorrectRate * 10) / 10.0);
        stats.put("totalQuizzes", allSubmissions.size());
        
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
    
    public Map<String, Object> checkEvolutionCondition() {
        Instructor instructor = getInstructor();
        
        Map<String, Object> result = new HashMap<>();
        result.put("canEvolve", false);
        result.put("currentLevel", instructor.getLevel());
        result.put("requiredLevel", 10);
        result.put("reasons", new ArrayList<String>());
        
        List<String> reasons = (List<String>) result.get("reasons");
        
        if (instructor.getLevel() < 10) {
            reasons.add("강사 레벨이 10 미만입니다");
        }
        
        if (instructor.getRageGauge() > 20) {
            reasons.add("분노 게이지가 너무 높습니다 (20 이하 필요)");
        }
        
        List<Student> students = studentRepository.findAll();
        if (!students.isEmpty()) {
            long totalCorrect = students.stream()
                .mapToLong(s -> s.getTotalCorrect() != null ? s.getTotalCorrect() : 0)
                .sum();
            long totalWrong = students.stream()
                .mapToLong(s -> s.getTotalWrong() != null ? s.getTotalWrong() : 0)
                .sum();
            
            double correctRate = totalCorrect + totalWrong > 0 
                ? (double) totalCorrect / (totalCorrect + totalWrong) * 100 
                : 0;
            
            result.put("studentCorrectRate", correctRate);
            result.put("requiredCorrectRate", 70.0);
            
            if (correctRate < 70.0) {
                reasons.add(String.format("학생 평균 정답률이 70%% 미만입니다 (현재: %.1f%%)", correctRate));
            }
        } else {
            reasons.add("등록된 학생이 없습니다");
        }
        
        boolean canEvolve = reasons.isEmpty() && !instructor.getIsEvolved();
        result.put("canEvolve", canEvolve);
        result.put("isAlreadyEvolved", instructor.getIsEvolved());
        
        return result;
    }

    @Transactional
    public Map<String, Object> tryAutoEvolve() {
        Map<String, Object> condition = checkEvolutionCondition();
        
        if ((Boolean) condition.get("canEvolve")) {
            Instructor evolved = evolveToFather();
            condition.put("evolved", true);
            condition.put("instructor", evolved);
            condition.put("message", "축하합니다! 허태훈이 아빠로 진화했습니다!");
        } else {
            condition.put("evolved", false);
        }
        
        return condition;
    }

    public List<Map<String, Object>> getRageHistory(int limit) {
        List<RageDialogue> dialogues = rageDialogueRepository.findAll(
            PageRequest.of(0, limit, Sort.by(Sort.Direction.DESC, "createdAt"))
        ).getContent();
        
        List<Map<String, Object>> history = new ArrayList<>();
        
        for (RageDialogue dialogue : dialogues) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", dialogue.getId());
            item.put("dialogueType", dialogue.getDialogueType());
            item.put("message", dialogue.getDialogueText());
            item.put("createdAt", dialogue.getCreatedAt());
            
            if (dialogue.getStudent() != null) {
                item.put("studentName", dialogue.getStudent().getDisplayName());
            }
            
            history.add(item);
        }
        
        return history;
    }
}
