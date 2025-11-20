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
            "너는 '%s' 스타일의 강사 AI야. 다음 조건으로 강의 스크립트를 생성해줘.\n\n" +
            "주제: %s\n" +
            "강의 계획:\n%s\n\n" +
            "난이도: %d/5\n" +
            "학생 분석: %s\n\n" +
            "요구사항:\n" +
            "1. 강사 스타일(%s)을 유지하며 강의 진행\n" +
            "2. 도입 → 핵심 개념 → 예제 → 심화 → 정리 순서\n" +
            "3. 각 섹션마다 학생 참여 유도 질문 포함\n" +
            "4. 실생활 예시 활용\n" +
            "5. 난이도에 맞는 설명 깊이\n" +
            "6. 학생 수준에 맞춘 설명\n\n" +
            "강의 스크립트를 생성해줘:",
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
            "=== %s 강의 ===\n\n" +
            "안녕하세요, 오늘은 %s에 대해 배워보겠습니다.\n\n" +
            "[도입]\n" +
            "이 주제는 난이도 %d 수준으로, 차근차근 따라오면 충분히 이해할 수 있습니다.\n\n" +
            "[핵심 개념]\n" +
            "%s의 기본 개념부터 시작하겠습니다...\n\n" +
            "[예제]\n" +
            "실제 예제를 통해 이해해봅시다...\n\n" +
            "[정리]\n" +
            "오늘 배운 내용을 정리하면...",
            topic, topic, difficulty, topic
        );
    }
    
    private int calculateDuration(String script) {
        int wordCount = script.length();
        return Math.max(10, wordCount / 100);
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
}
