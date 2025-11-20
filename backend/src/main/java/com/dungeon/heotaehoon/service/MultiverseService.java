package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.MultiverseInstructor;
import com.dungeon.heotaehoon.entity.SoulFragment;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.repository.MultiverseInstructorRepository;
import com.dungeon.heotaehoon.repository.SoulFragmentRepository;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MultiverseService {
    
    private final MultiverseInstructorRepository multiverseInstructorRepository;
    private final SoulFragmentRepository soulFragmentRepository;
    private final StudentRepository studentRepository;

    @Transactional
    public void initializeMultiverses() {
        if (multiverseInstructorRepository.count() == 0) {
            MultiverseInstructor coldBlooded = MultiverseInstructor.builder()
                .name("냉혈한 허태훈")
                .universeType("COLD_BLOODED")
                .description("감정이 없는 차가운 허태훈. 오답 시 데이터를 삭제하겠다고 위협한다.")
                .personalityTrait("무자비함")
                .difficultyMultiplier(1.5)
                .rewardMultiplier(1.8)
                .specialAbility("오답 3회 시 경험치 -50")
                .isUnlocked(true)
                .unlockCondition("기본 해금")
                .avatarEmoji("🥶")
                .build();

            MultiverseInstructor merciful = MultiverseInstructor.builder()
                .name("자비로운 허태훈")
                .universeType("MERCIFUL")
                .description("따뜻한 마음을 가진 허태훈. 문제를 풀면 간식을 추천해준다.")
                .personalityTrait("자비로움")
                .difficultyMultiplier(0.8)
                .rewardMultiplier(1.2)
                .specialAbility("정답 시 추가 포인트 +20")
                .isUnlocked(true)
                .unlockCondition("레벨 5 달성")
                .avatarEmoji("😇")
                .build();

            MultiverseInstructor cyborg = MultiverseInstructor.builder()
                .name("사이보그 허태훈")
                .universeType("CYBORG")
                .description("기계와 융합한 허태훈. 인간의 뇌로 이해 가능하겠냐고 묻는다.")
                .personalityTrait("논리적")
                .difficultyMultiplier(2.0)
                .rewardMultiplier(2.5)
                .specialAbility("정답 시 EXP 2배, 오답 시 -30")
                .isUnlocked(true)
                .unlockCondition("레벨 10 달성")
                .avatarEmoji("🤖")
                .build();

            multiverseInstructorRepository.save(coldBlooded);
            multiverseInstructorRepository.save(merciful);
            multiverseInstructorRepository.save(cyborg);
        }
    }

    public List<Map<String, Object>> getAvailableUniverses(String studentId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

        List<MultiverseInstructor> allUniverses = multiverseInstructorRepository.findAll();
        List<SoulFragment> obtainedFragments = soulFragmentRepository.findByStudent(student);

        return allUniverses.stream()
                .map(universe -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("id", universe.getId());
                    data.put("name", universe.getName());
                    data.put("universeType", universe.getUniverseType());
                    data.put("description", universe.getDescription());
                    data.put("personalityTrait", universe.getPersonalityTrait());
                    data.put("difficultyMultiplier", universe.getDifficultyMultiplier());
                    data.put("rewardMultiplier", universe.getRewardMultiplier());
                    data.put("specialAbility", universe.getSpecialAbility());
                    data.put("avatarEmoji", universe.getAvatarEmoji());
                    data.put("unlockCondition", universe.getUnlockCondition());

                    boolean hasFragment = obtainedFragments.stream()
                            .anyMatch(f -> f.getMultiverseInstructor().getId().equals(universe.getId()));
                    data.put("hasFragment", hasFragment);

                    boolean isUnlocked = checkUnlockCondition(student, universe);
                    data.put("isUnlocked", isUnlocked);

                    return data;
                })
                .collect(Collectors.toList());
    }

    private boolean checkUnlockCondition(Student student, MultiverseInstructor universe) {
        if (!universe.getIsUnlocked()) {
            return false;
        }

        String condition = universe.getUnlockCondition();
        if (condition == null || condition.equals("기본 해금")) {
            return true;
        }

        if (condition.contains("레벨 5") && student.getLevel() < 5) {
            return false;
        }

        if (condition.contains("레벨 10") && student.getLevel() < 10) {
            return false;
        }

        return true;
    }

    @Transactional
    public Map<String, Object> obtainSoulFragment(String studentId, String multiverseInstructorId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

        MultiverseInstructor instructor = multiverseInstructorRepository.findById(multiverseInstructorId)
                .orElseThrow(() -> new RuntimeException("멀티버스를 찾을 수 없습니다"));

        if (soulFragmentRepository.findByStudentAndMultiverseInstructor(student, instructor).isPresent()) {
            throw new RuntimeException("이미 획득한 영혼 조각입니다");
        }

        SoulFragment fragment = SoulFragment.builder()
                .student(student)
                .multiverseInstructor(instructor)
                .fragmentName(instructor.getName() + "의 영혼 조각")
                .description(instructor.getDescription())
                .build();

        soulFragmentRepository.save(fragment);

        long totalFragments = soulFragmentRepository.countByStudent(student);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("fragmentName", fragment.getFragmentName());
        result.put("totalFragments", totalFragments);
        result.put("canUnlockEnding", totalFragments >= 3);

        return result;
    }

    public Map<String, Object> getStudentProgress(String studentId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

        List<SoulFragment> fragments = soulFragmentRepository.findByStudent(student);
        long totalFragments = fragments.size();
        long totalUniverses = multiverseInstructorRepository.count();

        Map<String, Object> progress = new HashMap<>();
        progress.put("collectedFragments", totalFragments);
        progress.put("totalUniverses", totalUniverses);
        progress.put("canUnlockEnding", totalFragments >= 3);
        progress.put("fragments", fragments.stream().map(f -> {
            Map<String, Object> data = new HashMap<>();
            data.put("name", f.getFragmentName());
            data.put("universeName", f.getMultiverseInstructor().getName());
            data.put("universeType", f.getMultiverseInstructor().getUniverseType());
            data.put("obtainedAt", f.getObtainedAt());
            return data;
        }).collect(Collectors.toList()));

        return progress;
    }

    public Map<String, Object> unlockSpecialEnding(String studentId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));

        long totalFragments = soulFragmentRepository.countByStudent(student);

        if (totalFragments < 3) {
            throw new RuntimeException("영혼 조각이 부족합니다 (현재: " + totalFragments + "/3)");
        }

        student.setExp(student.getExp() + 1000);
        student.setPoints(student.getPoints() + 500);
        studentRepository.save(student);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("title", "허태훈의 영혼 완성");
        result.put("message", "모든 평행세계의 허태훈을 이해했습니다. 당신은 진정한 제자입니다.");
        result.put("rewards", Map.of(
            "exp", 1000,
            "points", 500,
            "title", "차원 여행자"
        ));

        return result;
    }
}
