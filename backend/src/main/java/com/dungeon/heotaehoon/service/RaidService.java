package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RaidService {
    
    private final RaidBossRepository raidBossRepository;
    private final RaidSessionRepository raidSessionRepository;
    private final RaidParticipantRepository raidParticipantRepository;
    private final StudentRepository studentRepository;
    private final StudentGroupRepository groupRepository;

    public List<RaidBoss> getActiveRaidBosses() {
        return raidBossRepository.findByIsActiveTrueAndIsDefeatedFalse();
    }

    public List<RaidSession> getActiveRaidSessions() {
        return raidSessionRepository.findBySessionStatusIn(List.of("waiting", "in_progress"));
    }

    @Transactional
    public Map<String, Object> createRaidSession(String raidBossId, String groupId) {
        RaidBoss raidBoss = raidBossRepository.findById(raidBossId)
                .orElseThrow(() -> new RuntimeException("레이드 보스를 찾을 수 없습니다"));

        StudentGroup group = null;
        if (groupId != null) {
            group = groupRepository.findById(groupId)
                    .orElseThrow(() -> new RuntimeException("그룹을 찾을 수 없습니다"));
        }

        LocalDateTime deadline = LocalDateTime.now().plusMinutes(raidBoss.getTimeLimitMinutes());

        RaidSession session = RaidSession.builder()
                .raidBoss(raidBoss)
                .group(group)
                .sessionStatus("waiting")
                .currentHp(raidBoss.getTotalHp())
                .totalDamageDealt(0)
                .participantCount(0)
                .deadline(deadline)
                .build();

        raidSessionRepository.save(session);

        Map<String, Object> result = new HashMap<>();
        result.put("session", session);
        result.put("message", "레이드 세션이 생성되었습니다");
        return result;
    }

    @Transactional
    public Map<String, Object> joinRaidSession(String sessionId, String studentId) {
        RaidSession session = raidSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("레이드 세션을 찾을 수 없습니다"));

        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

        if (raidParticipantRepository.findByRaidSessionIdAndStudentId(sessionId, studentId).isPresent()) {
            throw new RuntimeException("이미 참가한 레이드입니다");
        }

        RaidParticipant participant = RaidParticipant.builder()
                .raidSession(session)
                .student(student)
                .build();

        raidParticipantRepository.save(participant);

        session.setParticipantCount(session.getParticipantCount() + 1);
        raidSessionRepository.save(session);

        Map<String, Object> result = new HashMap<>();
        result.put("session", session);
        result.put("participant", participant);
        result.put("message", "레이드에 참가했습니다");
        return result;
    }

    @Transactional
    public Map<String, Object> startRaidSession(String sessionId) {
        RaidSession session = raidSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("레이드 세션을 찾을 수 없습니다"));

        if (session.getParticipantCount() < session.getRaidBoss().getMinParticipants()) {
            throw new RuntimeException("최소 참가 인원이 부족합니다");
        }

        session.setSessionStatus("in_progress");
        session.setStartedAt(LocalDateTime.now());
        raidSessionRepository.save(session);

        Map<String, Object> result = new HashMap<>();
        result.put("session", session);
        result.put("message", "레이드가 시작되었습니다!");
        return result;
    }

    @Transactional
    public Map<String, Object> dealDamage(String sessionId, String studentId, int damage) {
        RaidSession session = raidSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("레이드 세션을 찾을 수 없습니다"));

        if (!"in_progress".equals(session.getSessionStatus())) {
            throw new RuntimeException("진행 중인 레이드가 아닙니다");
        }

        RaidParticipant participant = raidParticipantRepository
                .findByRaidSessionIdAndStudentId(sessionId, studentId)
                .orElseThrow(() -> new RuntimeException("레이드 참가자가 아닙니다"));

        int newHp = Math.max(0, session.getCurrentHp() - damage);
        session.setCurrentHp(newHp);
        session.setTotalDamageDealt(session.getTotalDamageDealt() + damage);

        participant.setDamageDealt(participant.getDamageDealt() + damage);
        participant.setCorrectAnswers(participant.getCorrectAnswers() + 1);

        boolean isDefeated = newHp <= 0;

        if (isDefeated) {
            session.setSessionStatus("completed");
            session.setIsSuccess(true);
            session.setEndedAt(LocalDateTime.now());
            
            RaidBoss boss = session.getRaidBoss();
            boss.setIsDefeated(true);
            raidBossRepository.save(boss);
        }

        raidSessionRepository.save(session);
        raidParticipantRepository.save(participant);

        Map<String, Object> result = new HashMap<>();
        result.put("session", session);
        result.put("participant", participant);
        result.put("isDefeated", isDefeated);
        result.put("damageDealt", damage);
        result.put("message", isDefeated ? "보스 처치!" : "데미지 " + damage);
        return result;
    }

    @Transactional
    public Map<String, Object> claimReward(String sessionId, String studentId) {
        RaidSession session = raidSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("레이드 세션을 찾을 수 없습니다"));

        if (!session.getIsSuccess()) {
            throw new RuntimeException("성공한 레이드가 아닙니다");
        }

        RaidParticipant participant = raidParticipantRepository
                .findByRaidSessionIdAndStudentId(sessionId, studentId)
                .orElseThrow(() -> new RuntimeException("레이드 참가자가 아닙니다"));

        if (participant.getHasReceivedReward()) {
            throw new RuntimeException("이미 보상을 받았습니다");
        }

        Student student = participant.getStudent();
        RaidBoss boss = session.getRaidBoss();

        student.setExp(student.getExp() + boss.getRewardExp());
        student.setPoints(student.getPoints() + boss.getRewardPoints());

        while (student.getExp() >= 100) {
            student.setExp(student.getExp() - 100);
            student.setLevel(student.getLevel() + 1);
        }

        participant.setHasReceivedReward(true);

        studentRepository.save(student);
        raidParticipantRepository.save(participant);

        Map<String, Object> result = new HashMap<>();
        result.put("student", student);
        result.put("rewardExp", boss.getRewardExp());
        result.put("rewardPoints", boss.getRewardPoints());
        result.put("message", "보상을 받았습니다!");
        return result;
    }

    public Map<String, Object> getRaidSessionDetails(String sessionId) {
        RaidSession session = raidSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("레이드 세션을 찾을 수 없습니다"));

        List<RaidParticipant> participants = raidParticipantRepository.findByRaidSessionId(sessionId);

        Map<String, Object> result = new HashMap<>();
        result.put("session", session);
        result.put("participants", participants);
        result.put("boss", session.getRaidBoss());
        return result;
    }
}
