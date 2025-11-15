package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ExcelExportService {

    private final StudentSubmissionRepository submissionRepository;
    private final SubmissionAnswerRepository submissionAnswerRepository;
    private final StudentRepository studentRepository;
    private final WorksheetQuestionRepository questionRepository;
    private final PdfWorksheetRepository worksheetRepository;
    
    @Value("${openai.api.key:}")
    private String openaiApiKey;

    public byte[] generateGroupScoreExcel(String groupId, StudentGroup group) throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet(group.getGroupName());

        CellStyle headerStyle = createHeaderStyle(workbook);
        CellStyle dataStyle = createDataStyle(workbook);
        CellStyle centerStyle = createCenterStyle(workbook);

        List<Student> students = studentRepository.findByGroup(group);
        List<StudentSubmission> allSubmissions = students.stream()
            .flatMap(s -> submissionRepository.findByStudent(s).stream())
            .collect(Collectors.toList());
        
        List<WorksheetQuestion> allQuestions = new ArrayList<>();
        if (!allSubmissions.isEmpty()) {
            String worksheetId = allSubmissions.get(0).getWorksheet().getId();
            allQuestions = questionRepository.findByWorksheet_IdOrderByQuestionNumber(worksheetId);
        }

        int colNum = 0;
        int rowNum = 0;
        
        Row row0 = sheet.createRow(rowNum++);
        row0.createCell(colNum++).setCellValue("연번");
        row0.createCell(colNum++).setCellValue("이름");
        row0.createCell(colNum++).setCellValue("생년월일");
        
        for (WorksheetQuestion q : allQuestions) {
            Cell cell = row0.createCell(colNum++);
            cell.setCellValue(q.getQuestionType().equals("multiple_choice") ? "선다형" : "주관식");
            cell.setCellStyle(headerStyle);
        }
        
        row0.createCell(colNum++).setCellValue("재평가 유무");
        row0.createCell(colNum++).setCellValue("패널티 수준");
        row0.createCell(colNum++).setCellValue("최종점수");
        row0.createCell(colNum++).setCellValue("P/F");
        row0.createCell(colNum++).setCellValue("평가 의견");

        for (int i = 0; i < colNum; i++) {
            if (row0.getCell(i) != null) {
                row0.getCell(i).setCellStyle(headerStyle);
            }
        }

        colNum = 0;
        Row row1 = sheet.createRow(rowNum++);
        row1.createCell(colNum++).setCellValue("");
        row1.createCell(colNum++).setCellValue("");
        row1.createCell(colNum++).setCellValue("기준점수");
        
        for (WorksheetQuestion q : allQuestions) {
            Cell cell = row1.createCell(colNum++);
            cell.setCellValue(q.getPoints() != null ? q.getPoints() : 10);
            cell.setCellStyle(centerStyle);
        }
        
        row1.createCell(colNum++).setCellValue("");
        row1.createCell(colNum++).setCellValue("");
        row1.createCell(colNum++).setCellValue(100);
        row1.createCell(colNum++).setCellValue("");
        row1.createCell(colNum++).setCellValue("");

        colNum = 0;
        Row row2 = sheet.createRow(rowNum++);
        row2.createCell(colNum++).setCellValue("");
        row2.createCell(colNum++).setCellValue("");
        row2.createCell(colNum++).setCellValue("점수");
        
        for (int i = 0; i < allQuestions.size(); i++) {
            row2.createCell(colNum++).setCellValue("-");
        }
        
        row2.createCell(colNum++).setCellValue("");
        row2.createCell(colNum++).setCellValue("");
        row2.createCell(colNum++).setCellValue("");
        row2.createCell(colNum++).setCellValue("");
        row2.createCell(colNum++).setCellValue("");

        colNum = 0;
        Row row3 = sheet.createRow(rowNum++);
        row3.createCell(colNum++).setCellValue("");
        row3.createCell(colNum++).setCellValue("");
        row3.createCell(colNum++).setCellValue("비중");
        
        int totalPoints = allQuestions.stream().mapToInt(q -> q.getPoints() != null ? q.getPoints() : 10).sum();
        for (WorksheetQuestion q : allQuestions) {
            Cell cell = row3.createCell(colNum++);
            int points = q.getPoints() != null ? q.getPoints() : 10;
            double weight = totalPoints > 0 ? (points * 100.0 / totalPoints) : 0;
            cell.setCellValue(String.format("%.0f", weight));
            cell.setCellStyle(centerStyle);
        }
        
        row3.createCell(colNum++).setCellValue("");
        row3.createCell(colNum++).setCellValue("");
        row3.createCell(colNum++).setCellValue(100);
        row3.createCell(colNum++).setCellValue("");
        row3.createCell(colNum++).setCellValue("");

        int studentIndex = 1;
        for (Student student : students) {
            List<StudentSubmission> submissions = submissionRepository.findByStudent(student);
            
            if (submissions.isEmpty()) continue;
            
            StudentSubmission submission = submissions.get(0);
            List<SubmissionAnswer> answers = submissionAnswerRepository.findBySubmission(submission);
            Map<String, SubmissionAnswer> answerMap = answers.stream()
                .collect(Collectors.toMap(a -> a.getQuestion().getId(), a -> a));
            
            colNum = 0;
            Row dataRow = sheet.createRow(rowNum++);
            
            dataRow.createCell(colNum++).setCellValue(studentIndex++);
            dataRow.createCell(colNum++).setCellValue(student.getDisplayName());
            
            String birthDate = student.getBirthDate() != null ? student.getBirthDate() : "-";
            dataRow.createCell(colNum++).setCellValue(birthDate);
            
            StringBuilder correctTopics = new StringBuilder();
            for (WorksheetQuestion q : allQuestions) {
                SubmissionAnswer answer = answerMap.get(q.getId());
                Cell cell = dataRow.createCell(colNum++);
                if (answer != null) {
                    int points = answer.getIsCorrect() ? (q.getPoints() != null ? q.getPoints() : 10) : 0;
                    cell.setCellValue(points);
                    if (answer.getIsCorrect() && q.getQuestionText() != null) {
                        if (correctTopics.length() > 0) correctTopics.append("과 ");
                        String topic = q.getQuestionText().length() > 20 ? 
                            q.getQuestionText().substring(0, 20) : q.getQuestionText();
                        correctTopics.append(topic.replaceAll("[^a-zA-Z가-힣]", ""));
                    }
                } else {
                    cell.setCellValue(0);
                }
                cell.setCellStyle(centerStyle);
            }
            
            dataRow.createCell(colNum++).setCellValue("");
            dataRow.createCell(colNum++).setCellValue("5수준");
            
            int totalScore = submission.getTotalScore() != null ? submission.getTotalScore() : 0;
            dataRow.createCell(colNum++).setCellValue(totalScore);
            dataRow.createCell(colNum++).setCellValue(totalScore >= 60 ? "이수" : "미이수");
            
            String aiComment = generateDetailedAIComment(
                student.getDisplayName(), 
                totalScore,
                correctTopics.toString()
            );
            dataRow.createCell(colNum++).setCellValue(aiComment);
        }

        for (int i = 0; i < colNum; i++) {
            sheet.autoSizeColumn(i);
            if (sheet.getColumnWidth(i) > 15000) {
                sheet.setColumnWidth(i, 15000);
            }
        }

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();

        return outputStream.toByteArray();
    }

    public byte[] generateAllStudentsScoreExcel() throws IOException {
        return generateGroupScoreExcel(null, createDummyGroup());
    }

    private StudentGroup createDummyGroup() {
        StudentGroup group = new StudentGroup();
        group.setGroupName("전체학생");
        return group;
    }

    public byte[] generateWorksheetResultExcel(String worksheetId) throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("문제지결과");

        CellStyle headerStyle = createHeaderStyle(workbook);
        CellStyle dataStyle = createDataStyle(workbook);

        List<StudentSubmission> submissions = submissionRepository.findByWorksheet_Id(worksheetId);
        List<WorksheetQuestion> questions = questionRepository.findByWorksheet_IdOrderByQuestionNumber(worksheetId);

        int rowNum = 0;
        Row headerRow = sheet.createRow(rowNum++);
        
        headerRow.createCell(0).setCellValue("학생명");
        headerRow.createCell(1).setCellValue("아이디");
        headerRow.createCell(2).setCellValue("제출일시");
        headerRow.createCell(3).setCellValue("총점");
        
        for (int i = 0; i < questions.size(); i++) {
            headerRow.createCell(4 + i).setCellValue("Q" + (i + 1));
        }
        
        headerRow.createCell(4 + questions.size()).setCellValue("정답률");

        for (int i = 0; i <= 4 + questions.size(); i++) {
            if (headerRow.getCell(i) != null) {
                headerRow.getCell(i).setCellStyle(headerStyle);
            }
        }

        for (StudentSubmission submission : submissions) {
            Row row = sheet.createRow(rowNum++);
            
            List<SubmissionAnswer> answers = submissionAnswerRepository.findBySubmission(submission);
            Map<String, SubmissionAnswer> answerMap = answers.stream()
                .collect(Collectors.toMap(a -> a.getQuestion().getId(), a -> a));
            
            long correctCount = answers.stream().filter(SubmissionAnswer::getIsCorrect).count();
            double accuracy = questions.size() > 0 ? (correctCount * 100.0 / questions.size()) : 0.0;

            row.createCell(0).setCellValue(submission.getStudent().getDisplayName());
            row.createCell(1).setCellValue(submission.getStudent().getUsername());
            row.createCell(2).setCellValue(submission.getSubmittedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            row.createCell(3).setCellValue(submission.getTotalScore() != null ? submission.getTotalScore() : 0);
            
            for (int i = 0; i < questions.size(); i++) {
                WorksheetQuestion question = questions.get(i);
                SubmissionAnswer answer = answerMap.get(question.getId());
                String cellValue = answer != null ? (answer.getIsCorrect() ? "O" : "X") : "-";
                row.createCell(4 + i).setCellValue(cellValue);
            }
            
            row.createCell(4 + questions.size()).setCellValue(String.format("%.1f%%", accuracy));

            for (int i = 0; i <= 4 + questions.size(); i++) {
                if (row.getCell(i) != null) {
                    row.getCell(i).setCellStyle(dataStyle);
                }
            }
        }

        for (int i = 0; i <= 4 + questions.size(); i++) {
            sheet.autoSizeColumn(i);
        }

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();

        return outputStream.toByteArray();
    }

    private String generateDetailedAIComment(String studentName, int score, String correctTopics) {
        if (openaiApiKey == null || openaiApiKey.isEmpty()) {
            if (correctTopics.length() > 0) {
                return String.format("%s에서 양호함.", correctTopics);
            }
            return "전반적인 학습이 필요합니다.";
        }

        try {
            RestTemplate restTemplate = new RestTemplate();
            String url = "https://api.openai.com/v1/chat/completions";
            
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", "gpt-4");
            requestBody.put("messages", List.of(
                Map.of("role", "system", "content", "당신은 교육 전문가입니다. 학생의 성적을 보고 1-2문장의 간결한 평가를 작성하세요."),
                Map.of("role", "user", "content", String.format("%s 학생의 점수: %d점. 정답 주제: %s. 간결한 평가를 작성해주세요.", studentName, score, correctTopics.isEmpty() ? "없음" : correctTopics))
            ));
            requestBody.put("max_tokens", 100);
            
            org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
            headers.set("Authorization", "Bearer " + openaiApiKey);
            headers.set("Content-Type", "application/json");
            
            org.springframework.http.HttpEntity<Map<String, Object>> entity = new org.springframework.http.HttpEntity<>(requestBody, headers);
            Map<String, Object> response = restTemplate.postForObject(url, entity, Map.class);
            
            List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
            if (choices != null && !choices.isEmpty()) {
                Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
                return (String) message.get("content");
            }
        } catch (Exception e) {
            if (correctTopics.length() > 0) {
                return String.format("%s에서 양호함.", correctTopics);
            }
            return "전반적인 학습이 필요합니다.";
        }
        
        if (correctTopics.length() > 0) {
            return String.format("%s에서 양호함.", correctTopics);
        }
        return "지속적인 학습을 권장합니다.";
    }

    private CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 11);
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    private CellStyle createDataStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    private CellStyle createCenterStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }
}
