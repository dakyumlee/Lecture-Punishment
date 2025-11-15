package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
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
        CellStyle metaStyle = createMetaStyle(workbook);

        int rowNum = 0;

        Row metaRow1 = sheet.createRow(rowNum++);
        metaRow1.createCell(0).setCellValue("과정명");
        Cell courseCell = metaRow1.createCell(1).setCellValue(group.getCourse() != null ? group.getCourse() : "");
        courseCell.setCellStyle(metaStyle);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 1, 5));

        Row metaRow2 = sheet.createRow(rowNum++);
        metaRow2.createCell(0).setCellValue("능력단위");
        Cell abilityCell = metaRow2.createCell(1);
        abilityCell.setCellValue(group.getGroupName());
        abilityCell.setCellStyle(metaStyle);
        sheet.addMergedRegion(new CellRangeAddress(1, 1, 1, 5));

        Row metaRow3 = sheet.createRow(rowNum++);
        metaRow3.createCell(0).setCellValue("평가일");
        Cell dateCell = metaRow3.createCell(1);
        dateCell.setCellValue(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
        dateCell.setCellStyle(metaStyle);

        Row metaRow4 = sheet.createRow(rowNum++);
        metaRow4.createCell(0).setCellValue("담당교사");
        Cell teacherCell = metaRow4.createCell(1);
        teacherCell.setCellValue("허태훈");
        teacherCell.setCellStyle(metaStyle);

        Row metaRow5 = sheet.createRow(rowNum++);
        metaRow5.createCell(0).setCellValue("배점구조");
        Cell scoreCell = metaRow5.createCell(1);
        scoreCell.setCellValue("출석(20점) + 과제(30점) + 시험(50점) = 총점(100점)");
        scoreCell.setCellStyle(metaStyle);
        sheet.addMergedRegion(new CellRangeAddress(4, 4, 1, 5));

        rowNum++;

        Row headerRow = sheet.createRow(rowNum++);
        String[] headers = {"연번", "이름", "생년월일", "출석", "과제", "시험", "총점", "P/F", "평가 의견"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }

        List<Student> students = studentRepository.findByGroup(group);
        int studentIndex = 1;

        for (Student student : students) {
            List<StudentSubmission> submissions = submissionRepository.findByStudent(student);
            
            if (submissions.isEmpty()) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(studentIndex++);
                row.createCell(1).setCellValue(student.getDisplayName());
                row.createCell(2).setCellValue(student.getBirthDate() != null ? student.getBirthDate().toString() : "-");
                row.createCell(3).setCellValue(0);
                row.createCell(4).setCellValue(0);
                row.createCell(5).setCellValue(0);
                row.createCell(6).setCellValue(0);
                row.createCell(7).setCellValue("미이수");
                row.createCell(8).setCellValue("제출 기록 없음");
                continue;
            }
            
            StudentSubmission submission = submissions.get(0);
            List<SubmissionAnswer> answers = submissionAnswerRepository.findBySubmission(submission);
            
            int attendanceScore = 20;
            int assignmentScore = 30;
            int examScore = submission.getTotalScore() != null ? (int) (submission.getTotalScore() * 0.5) : 0;
            int totalScore = attendanceScore + assignmentScore + examScore;
            
            String pf = determinePF(totalScore, attendanceScore);
            String aiComment = generateAIComment(
                student.getDisplayName(),
                group.getGroupName(),
                attendanceScore,
                assignmentScore,
                examScore,
                totalScore,
                pf
            );

            Row row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(studentIndex++);
            row.createCell(1).setCellValue(student.getDisplayName());
            row.createCell(2).setCellValue(student.getBirthDate() != null ? student.getBirthDate().toString() : "-");
            row.createCell(3).setCellValue(attendanceScore);
            row.createCell(4).setCellValue(assignmentScore);
            row.createCell(5).setCellValue(examScore);
            row.createCell(6).setCellValue(totalScore);
            row.createCell(7).setCellValue(pf);
            row.createCell(8).setCellValue(aiComment);

            for (int i = 0; i < 9; i++) {
                if (row.getCell(i) != null) {
                    row.getCell(i).setCellStyle(dataStyle);
                }
            }
        }

        for (int i = 0; i < 9; i++) {
            sheet.autoSizeColumn(i);
            if (i == 8 && sheet.getColumnWidth(8) > 20000) {
                sheet.setColumnWidth(8, 20000);
            }
        }

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();

        return outputStream.toByteArray();
    }

    public byte[] generateAllStudentsScoreExcel() throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("전체학생");

        CellStyle headerStyle = createHeaderStyle(workbook);
        CellStyle dataStyle = createDataStyle(workbook);

        int rowNum = 0;

        Row headerRow = sheet.createRow(rowNum++);
        String[] headers = {"연번", "그룹", "이름", "생년월일", "출석", "과제", "시험", "총점", "P/F", "평가 의견"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }

        List<Student> students = studentRepository.findAll();
        int studentIndex = 1;

        for (Student student : students) {
            List<StudentSubmission> submissions = submissionRepository.findByStudent(student);
            
            String groupName = student.getGroup() != null ? student.getGroup().getGroupName() : "미배정";
            
            if (submissions.isEmpty()) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(studentIndex++);
                row.createCell(1).setCellValue(groupName);
                row.createCell(2).setCellValue(student.getDisplayName());
                row.createCell(3).setCellValue(student.getBirthDate() != null ? student.getBirthDate().toString() : "-");
                row.createCell(4).setCellValue(0);
                row.createCell(5).setCellValue(0);
                row.createCell(6).setCellValue(0);
                row.createCell(7).setCellValue(0);
                row.createCell(8).setCellValue("미이수");
                row.createCell(9).setCellValue("제출 기록 없음");
                continue;
            }
            
            StudentSubmission submission = submissions.get(0);
            
            int attendanceScore = 20;
            int assignmentScore = 30;
            int examScore = submission.getTotalScore() != null ? (int) (submission.getTotalScore() * 0.5) : 0;
            int totalScore = attendanceScore + assignmentScore + examScore;
            
            String pf = determinePF(totalScore, attendanceScore);
            String aiComment = generateAIComment(
                student.getDisplayName(),
                groupName,
                attendanceScore,
                assignmentScore,
                examScore,
                totalScore,
                pf
            );

            Row row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(studentIndex++);
            row.createCell(1).setCellValue(groupName);
            row.createCell(2).setCellValue(student.getDisplayName());
            row.createCell(3).setCellValue(student.getBirthDate() != null ? student.getBirthDate().toString() : "-");
            row.createCell(4).setCellValue(attendanceScore);
            row.createCell(5).setCellValue(assignmentScore);
            row.createCell(6).setCellValue(examScore);
            row.createCell(7).setCellValue(totalScore);
            row.createCell(8).setCellValue(pf);
            row.createCell(9).setCellValue(aiComment);

            for (int i = 0; i < 10; i++) {
                if (row.getCell(i) != null) {
                    row.getCell(i).setCellStyle(dataStyle);
                }
            }
        }

        for (int i = 0; i < 10; i++) {
            sheet.autoSizeColumn(i);
            if (i == 9 && sheet.getColumnWidth(9) > 20000) {
                sheet.setColumnWidth(9, 20000);
            }
        }

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();

        return outputStream.toByteArray();
    }

    public byte[] generateWorksheetResultExcel(String worksheetId) throws IOException {
        return generateAllStudentsScoreExcel();
    }

    private String determinePF(int totalScore, int attendanceScore) {
        if (attendanceScore < 16) return "미이수";
        if (totalScore < 60) return "미이수";
        if (totalScore >= 95) return "우수";
        return "이수";
    }

    private String generateAIComment(String studentName, String groupName, 
                                     int attendance, int assignment, int exam, 
                                     int total, String pf) {
        if (openaiApiKey == null || openaiApiKey.isEmpty()) {
            if (pf.equals("우수")) {
                return String.format("%s 능력단위에서 우수한 성과를 보였으며 전반적으로 학습 태도가 모범적임.", groupName);
            } else if (pf.equals("미이수")) {
                return String.format("%s 능력단위 기초 개념 이해는 있으나 실습 수행도가 기준 미달. 추가 학습 필요.", groupName);
            } else {
                return String.format("%s 능력단위에서 안정적인 이해도를 보이며 수업 참여도가 양호함.", groupName);
            }
        }

        try {
            RestTemplate restTemplate = new RestTemplate();
            String url = "https://api.openai.com/v1/chat/completions";
            
            String prompt = String.format(
                "%s 학생 - %s 과정 평가\n출석: %d점, 과제: %d점, 시험: %d점, 총점: %d점, 판정: %s\n" +
                "위 점수를 바탕으로 1-2문장의 간결하고 구체적인 평가 의견을 작성하세요. " +
                "긍정적이고 건설적인 톤으로 작성하되, 점수가 낮으면 보완점을 언급하세요.",
                studentName, groupName, attendance, assignment, exam, total, pf
            );
            
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", "gpt-4");
            requestBody.put("messages", List.of(
                Map.of("role", "system", "content", "당신은 교육 평가 전문가입니다."),
                Map.of("role", "user", "content", prompt)
            ));
            requestBody.put("max_tokens", 150);
            
            org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
            headers.set("Authorization", "Bearer " + openaiApiKey);
            headers.set("Content-Type", "application/json");
            
            org.springframework.http.HttpEntity<Map<String, Object>> entity = 
                new org.springframework.http.HttpEntity<>(requestBody, headers);
            Map<String, Object> response = restTemplate.postForObject(url, entity, Map.class);
            
            List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
            if (choices != null && !choices.isEmpty()) {
                Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
                return (String) message.get("content");
            }
        } catch (Exception e) {
            log.error("AI comment generation failed", e);
        }
        
        if (pf.equals("우수")) {
            return String.format("%s 능력단위에서 우수한 성과를 보였으며 전반적으로 학습 태도가 모범적임.", groupName);
        } else if (pf.equals("미이수")) {
            return String.format("%s 능력단위 기초 개념 이해는 있으나 실습 수행도가 기준 미달. 추가 학습 필요.", groupName);
        } else {
            return String.format("%s 능력단위에서 안정적인 이해도를 보이며 수업 참여도가 양호함.", groupName);
        }
    }

    private CellStyle createMetaStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 11);
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.LEFT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
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
        style.setWrapText(true);
        return style;
    }
}
