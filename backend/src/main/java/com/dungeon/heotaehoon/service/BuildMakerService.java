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
public class BuildMakerService {
    
    private final AILectureRepository aiLectureRepository;
    private final LectureProgressRepository lectureProgressRepository;
    private final StudentRepository studentRepository;
    private final QuizResultRepository quizResultRepository;
    private final AIService aiService;
    
    @Transactional
    public Map<String, Object> generateAILecture(Map<String, Object> request) {
        String topic = (String) request.get("topic");
        String syllabus = (String) request.get("syllabus");
        Integer difficulty = (Integer) request.getOrDefault("difficulty", 3);
        String instructorStyle = (String) request.getOrDefault("instructorStyle", "허태훈");
        
        String studentAnalysis = analyzeStudentPerformance(topic);
        
        String lectureScript = generateLectureScript(topic, syllabus, difficulty, instructorStyle, studentAnalysis);
        
        AILecture lecture = AILecture.builder()
            .lectureName(topic + " - AI 강의")
            .topic(topic)
            .syllabus(syllabus)
            .difficulty(difficulty)
            .generatedScript(lectureScript)
            .instructorStyle(instructorStyle)
            .studentAnalysis(studentAnalysis)
            .estimatedDuration(calculateDuration(lectureScript))
            .isActive(true)
            .build();
        
        aiLectureRepository.save(lecture);
        
        Map<String, Object> response = new HashMap<>();
        response.put("lectureId", lecture.getId());
        response.put("lectureName", lecture.getLectureName());
        response.put("difficulty", lecture.getDifficulty());
        response.put("estimatedDuration", lecture.getEstimatedDuration());
        response.put("preview", lectureScript.substring(0, Math.min(200, lectureScript.length())));
        
        return response;
    }
    
    private String analyzeStudentPerformance(String topic) {
        List<QuizResult> recentResults = quizResultRepository.findTop10ByOrderBySubmittedAtDesc();
        
        if (recentResults.isEmpty()) {
            return "학생 데이터 없음 - 일반적인 강의 진행";
        }
        
        long correctCount = recentResults.stream()
            .filter(QuizResult::getIsCorrect)
            .count();
        
        double correctRate = (double) correctCount / recentResults.size() * 100;
        
        StringBuilder analysis = new StringBuilder();
        analysis.append("최근 정답률: ").append(String.format("%.1f", correctRate)).append("%. ");
        
        if (correctRate < 40) {
            analysis.append("기초부터 천천히 설명 필요. ");
        } else if (correctRate < 70) {
            analysis.append("중간 난이도 유지하되 어려운 부분 반복 설명. ");
        } else {
            analysis.append("심화 내용 추가 가능. ");
        }
        
        if (correctCount < 3) {
            analysis.append("많은 학생들이 어려워하므로 예제 중심 설명. ");
        }
        
        return analysis.toString();
    }
    
    private String generateLectureScript(String topic, String syllabus, int difficulty, String style, String studentAnalysis) {
        String prompt = String.format(
            "너는 '%s' 스타일의 강사야. 다음 조건으로 상세한 강의를 작성해줘.\n\n" +
            "주제: %s\n" +
            "강의 계획:\n%s\n\n" +
            "난이도: %d/5\n" +
            "학생 분석: %s\n\n" +
            "중요한 규칙:\n" +
            "1. 마크다운 기호(#, ##, ###, *, -, >)를 절대 사용하지 마\n" +
            "2. 일반 텍스트로만 작성할 것\n" +
            "3. 섹션 구분은 [도입], [핵심개념], [예제], [실습], [심화], [정리]로 할 것\n" +
            "4. 각 섹션마다 최소 5문장 이상 상세하게 설명\n" +
            "5. 실제 코드 예제나 구체적인 사례를 반드시 포함\n" +
            "6. 학생이 직접 따라할 수 있는 단계별 설명\n" +
            "7. 강사 스타일(%s)을 유지하되 이해하기 쉽게\n" +
            "8. 최소 2000자 이상 작성\n\n" +
            "강의 구조:\n" +
            "[도입]\n" +
            "- 왜 이 주제가 중요한지\n" +
            "- 실생활 예시\n" +
            "- 학습 목표\n\n" +
            "[핵심개념]\n" +
            "- 기본 개념 상세 설명\n" +
            "- 용어 정의\n" +
            "- 주의사항\n\n" +
            "[예제]\n" +
            "- 구체적인 예제 코드나 사례\n" +
            "- 단계별 설명\n\n" +
            "[실습]\n" +
            "- 학생이 직접 해볼 수 있는 문제\n" +
            "- 힌트 제공\n\n" +
            "[심화]\n" +
            "- 더 깊은 내용\n" +
            "- 실무 팁\n\n" +
            "[정리]\n" +
            "- 핵심 요약\n" +
            "- 다음 학습 방향\n\n" +
            "강의를 작성해줘:",
            style, topic, syllabus, difficulty, studentAnalysis, style
        );
        
        try {
            return aiService.generateText(prompt);
        } catch (Exception e) {
            return generateDefaultScript(topic, difficulty);
        }
    }
    
    private String generateDefaultScript(String topic, int difficulty) {
        return String.format(
            "[도입]\n\n" +
            "안녕하세요, 오늘은 %s에 대해 배워보겠습니다.\n\n" +
            "이 주제는 난이도 %d 수준으로, 차근차근 따라오면 충분히 이해할 수 있습니다. " +
            "실무에서 자주 사용되는 중요한 개념이므로 집중해서 들어주세요.\n\n" +
            "[핵심개념]\n\n" +
            "%s의 기본 개념부터 시작하겠습니다.\n\n" +
            "먼저 용어를 정의하면, %s란 프로그래밍에서 특정 목적을 달성하기 위해 사용하는 기법입니다. " +
            "이를 이해하려면 먼저 기본적인 원리를 알아야 합니다.\n\n" +
            "핵심 포인트는 다음과 같습니다:\n" +
            "1. 기본 구조를 이해한다\n" +
            "2. 실제 사용 사례를 본다\n" +
            "3. 주의사항을 숙지한다\n\n" +
            "[예제]\n\n" +
            "실제 예제를 통해 이해해봅시다.\n\n" +
            "예를 들어, 일상생활에서 %s를 사용한다면 어떻게 될까요? " +
            "구체적인 코드로 보면 이렇습니다.\n\n" +
            "단계 1: 먼저 기본 설정을 합니다\n" +
            "단계 2: 핵심 로직을 작성합니다\n" +
            "단계 3: 결과를 확인합니다\n\n" +
            "[실습]\n\n" +
            "이제 직접 해볼 차례입니다.\n\n" +
            "다음 문제를 풀어보세요: %s를 활용해서 간단한 프로그램을 만들어보세요. " +
            "힌트: 앞에서 배운 기본 구조를 그대로 따라하면 됩니다.\n\n" +
            "[심화]\n\n" +
            "조금 더 깊이 들어가봅시다.\n\n" +
            "실무에서는 %s를 더 효율적으로 사용하는 방법이 있습니다. " +
            "성능 최적화, 에러 처리, 확장성 등을 고려해야 합니다.\n\n" +
            "[정리]\n\n" +
            "오늘 배운 내용을 정리하면:\n" +
            "1. %s의 기본 개념\n" +
            "2. 실제 사용 방법\n" +
            "3. 주의사항과 팁\n\n" +
            "다음 시간에는 이를 바탕으로 더 복잡한 예제를 다뤄보겠습니다. 수고하셨습니다!",
            topic, difficulty, topic, topic, topic, topic, topic, topic, topic
        );
    }
    
    private int calculateDuration(String script) {
        int wordCount = script.length();
        return Math.max(15, wordCount / 80);
    }
    
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllLectures() {
        List<AILecture> lectures = aiLectureRepository.findByIsActiveTrueOrderByCreatedAtDesc();
        
        List<Map<String, Object>> response = new ArrayList<>();
        for (AILecture lecture : lectures) {
            Map<String, Object> lectureInfo = new HashMap<>();
            lectureInfo.put("id", lecture.getId());
            lectureInfo.put("lectureName", lecture.getLectureName());
            lectureInfo.put("topic", lecture.getTopic());
            lectureInfo.put("difficulty", lecture.getDifficulty());
            lectureInfo.put("estimatedDuration", lecture.getEstimatedDuration());
            lectureInfo.put("instructorStyle", lecture.getInstructorStyle());
            response.add(lectureInfo);
        }
        
        return response;
    }
    
    @Transactional(readOnly = true)
    public Map<String, Object> getLectureDetail(Long lectureId) {
        AILecture lecture = aiLectureRepository.findById(lectureId)
            .orElseThrow(() -> new RuntimeException("강의를 찾을 수 없습니다"));
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", lecture.getId());
        response.put("lectureName", lecture.getLectureName());
        response.put("topic", lecture.getTopic());
        response.put("syllabus", lecture.getSyllabus());
        response.put("difficulty", lecture.getDifficulty());
        response.put("script", lecture.getGeneratedScript());
        response.put("instructorStyle", lecture.getInstructorStyle());
        response.put("estimatedDuration", lecture.getEstimatedDuration());
        response.put("studentAnalysis", lecture.getStudentAnalysis());
        
        return response;
    }
    
    @Transactional
    public Map<String, Object> updateProgress(String studentId, Long lectureId, int currentSection) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
        
        AILecture lecture = aiLectureRepository.findById(lectureId)
            .orElseThrow(() -> new RuntimeException("강의를 찾을 수 없습니다"));
        
        LectureProgress progress = lectureProgressRepository.findByStudentAndLecture(student, lecture)
            .orElseGet(() -> LectureProgress.builder()
                .student(student)
                .lecture(lecture)
                .totalSections(10)
                .comprehensionScore(0)
                .build());
        
        progress.setCurrentSection(currentSection);
        progress.setCompletionRate((double) currentSection / progress.getTotalSections() * 100);
        progress.setLastAccessedAt(LocalDateTime.now());
        
        if (currentSection >= progress.getTotalSections()) {
            progress.setIsCompleted(true);
            progress.setCompletionRate(100.0);
        }
        
        lectureProgressRepository.save(progress);
        
        Map<String, Object> response = new HashMap<>();
        response.put("currentSection", progress.getCurrentSection());
        response.put("completionRate", progress.getCompletionRate());
        response.put("isCompleted", progress.getIsCompleted());
        
        return response;
    }
    
    @Transactional(readOnly = true)
    public Map<String, Object> getStudentProgress(String studentId, Long lectureId) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
        
        AILecture lecture = aiLectureRepository.findById(lectureId)
            .orElseThrow(() -> new RuntimeException("강의를 찾을 수 없습니다"));
        
        LectureProgress progress = lectureProgressRepository.findByStudentAndLecture(student, lecture)
            .orElse(null);
        
        Map<String, Object> response = new HashMap<>();
        if (progress != null) {
            response.put("currentSection", progress.getCurrentSection());
            response.put("completionRate", progress.getCompletionRate());
            response.put("isCompleted", progress.getIsCompleted());
            response.put("comprehensionScore", progress.getComprehensionScore());
        } else {
            response.put("currentSection", 0);
            response.put("completionRate", 0.0);
            response.put("isCompleted", false);
            response.put("comprehensionScore", 0);
        }
        
        return response;
    }

    @Transactional
    public boolean deleteLecture(Long lectureId) {
        try {
            AILecture lecture = aiLectureRepository.findById(lectureId)
                .orElseThrow(() -> new RuntimeException("강의를 찾을 수 없습니다"));
            
            lecture.setIsActive(false);
            aiLectureRepository.save(lecture);
            
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
