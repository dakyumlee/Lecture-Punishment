package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

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

    private final AiEvaluationService aiEvaluationService;

    public byte[] generateGradingReport(
        Worksheet worksheet,
        List<StudentSubmission> submissions,
        List<WorksheetQuestion> questions
    ) throws IOException {
        
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("평가결과");
            
            createHeaderSection(workbook, sheet, worksheet, questions);
            createStudentGrades(workbook, sheet, submissions, questions, worksheet);
            
            autoSizeColumns(sheet, questions.size());
            
            workbook.write(out);
            return out.toByteArray();
        }
    }

    private void createHeaderSection(
        Workbook workbook,
        Sheet sheet,
        Worksheet worksheet,
        List<WorksheetQuestion> questions
    ) {
        CellStyle headerStyle = createHeaderStyle(workbook);
        CellStyle titleStyle = createTitleStyle(workbook);
        CellStyle infoStyle = createInfoStyle(workbook);
        
        Row row0 = sheet.createRow(0);
        Cell titleCell = row0.createCell(0);
        titleCell.setCellValue("평가결과표");
        titleCell.setCellStyle(titleStyle);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 5));
        
        Row row2 = sheet.createRow(2);
        Cell courseLabel = row2.createCell(0);
        courseLabel.setCellValue("과정명");
        courseLabel.setCellStyle(headerStyle);
        
        Cell courseValue = row2.createCell(1);
        courseValue.setCellValue(worksheet.getGroup() != null ? 
            worksheet.getGroup().getGroupName() : "전체");
        courseValue.setCellStyle(infoStyle);
        sheet.addMergedRegion(new CellRangeAddress(2, 2, 1, 3));
        
        Cell dateLabel = row2.createCell(4);
        dateLabel.setCellValue("평가일시");
        dateLabel.setCellStyle(headerStyle);
        
        Cell dateValue = row2.createCell(5);
        dateValue.setCellValue(LocalDateTime.now()
            .format(DateTimeFormatter.ofPattern("yyyy년 MM월 dd일")));
        dateValue.setCellStyle(infoStyle);
        sheet.addMergedRegion(new CellRangeAddress(2, 2, 5, 6));
        
        Row row3 = sheet.createRow(3);
        Cell titleLabel = row3.createCell(0);
        titleLabel.setCellValue("문제지");
        titleLabel.setCellStyle(headerStyle);
        
        Cell titleValue = row3.createCell(1);
        titleValue.setCellValue(worksheet.getTitle());
        titleValue.setCellStyle(infoStyle);
        sheet.addMergedRegion(new CellRangeAddress(3, 3, 1, 3));
        
        Cell totalLabel = row3.createCell(4);
        totalLabel.setCellValue("총점");
        totalLabel.setCellStyle(headerStyle);
        
        Cell totalValue = row3.createCell(5);
        int totalPoints = questions.stream()
            .mapToInt(WorksheetQuestion::getPoints)
            .sum();
        totalValue.setCellValue(totalPoints);
        totalValue.setCellStyle(infoStyle);
        
        Cell countLabel = row3.createCell(6);
        countLabel.setCellValue("문항수");
        countLabel.setCellStyle(headerStyle);
        
        Cell countValue = row3.createCell(7);
        countValue.setCellValue(questions.size());
        countValue.setCellStyle(infoStyle);
    }

    private void createStudentGrades(
        Workbook workbook,
        Sheet sheet,
        List<StudentSubmission> submissions,
        List<WorksheetQuestion> questions,
        Worksheet worksheet
    ) {
        CellStyle columnHeaderStyle = createColumnHeaderStyle(workbook);
        CellStyle cellStyle = createCellStyle(workbook);
        CellStyle centerStyle = createCenterStyle(workbook);
        CellStyle evaluationStyle = createEvaluationStyle(workbook);
        
        Row headerRow = sheet.createRow(5);
        
        Cell noCell = headerRow.createCell(0);
        noCell.setCellValue("번호");
        noCell.setCellStyle(columnHeaderStyle);
        
        Cell nameCell = headerRow.createCell(1);
        nameCell.setCellValue("이름");
        nameCell.setCellStyle(columnHeaderStyle);
        
        Cell idCell = headerRow.createCell(2);
        idCell.setCellValue("아이디");
        idCell.setCellStyle(columnHeaderStyle);
        
        for (int i = 0; i < questions.size(); i++) {
            Cell qCell = headerRow.createCell(3 + i);
            WorksheetQuestion q = questions.get(i);
            qCell.setCellValue((i + 1) + "번\n(" + q.getPoints() + "점)");
            qCell.setCellStyle(columnHeaderStyle);
        }
        
        Cell totalCell = headerRow.createCell(3 + questions.size());
        totalCell.setCellValue("총점");
        totalCell.setCellStyle(columnHeaderStyle);
        
        Cell avgCell = headerRow.createCell(4 + questions.size());
        avgCell.setCellValue("평균");
        avgCell.setCellStyle(columnHeaderStyle);
        
        Cell evalCell = headerRow.createCell(5 + questions.size());
        evalCell.setCellValue("평가의견");
        evalCell.setCellStyle(columnHeaderStyle);
        sheet.setColumnWidth(5 + questions.size(), 15000);
        
        int rowNum = 6;
        for (int i = 0; i < submissions.size(); i++) {
            StudentSubmission submission = submissions.get(i);
            Row row = sheet.createRow(rowNum++);
            
            Cell noDataCell = row.createCell(0);
            noDataCell.setCellValue(i + 1);
            noDataCell.setCellStyle(centerStyle);
            
            Cell nameDataCell = row.createCell(1);
            nameDataCell.setCellValue(submission.getStudent().getDisplayName());
            nameDataCell.setCellStyle(cellStyle);
            
            Cell idDataCell = row.createCell(2);
            idDataCell.setCellValue(submission.getStudent().getUsername());
            idDataCell.setCellStyle(cellStyle);
            
            int totalScore = 0;
            List<Map<String, Object>> wrongQuestions = new ArrayList<>();
            
            for (int j = 0; j < questions.size(); j++) {
                WorksheetQuestion question = questions.get(j);
                Cell scoreCell = row.createCell(3 + j);
                
                Optional<SubmissionAnswer> answerOpt = submission.getAnswers().stream()
                    .filter(a -> a.getQuestion().getId().equals(question.getId()))
                    .findFirst();
                
                if (answerOpt.isPresent()) {
                    SubmissionAnswer answer = answerOpt.get();
                    int score = answer.getPointsEarned() != null ? answer.getPointsEarned() : 0;
                    scoreCell.setCellValue(score);
                    totalScore += score;
                    
                    if (score == 0 || score < question.getPoints()) {
                        Map<String, Object> wrongQ = new HashMap<>();
                        wrongQ.put("questionNumber", j + 1);
                        wrongQ.put("questionText", question.getQuestionText());
                        wrongQuestions.add(wrongQ);
                    }
                } else {
                    scoreCell.setCellValue(0);
                    
                    Map<String, Object> wrongQ = new HashMap<>();
                    wrongQ.put("questionNumber", j + 1);
                    wrongQ.put("questionText", question.getQuestionText());
                    wrongQuestions.add(wrongQ);
                }
                scoreCell.setCellStyle(centerStyle);
            }
            
            Cell totalDataCell = row.createCell(3 + questions.size());
            totalDataCell.setCellValue(totalScore);
            totalDataCell.setCellStyle(centerStyle);
            
            int maxScore = questions.stream().mapToInt(WorksheetQuestion::getPoints).sum();
            double average = maxScore > 0 ? (double) totalScore / maxScore * 100 : 0;
            
            Cell avgDataCell = row.createCell(4 + questions.size());
            avgDataCell.setCellValue(String.format("%.1f%%", average));
            avgDataCell.setCellStyle(centerStyle);
            
            String evaluation = aiEvaluationService.generateEvaluation(
                submission.getStudent().getDisplayName(),
                totalScore,
                maxScore,
                wrongQuestions
            );
            
            Cell evalDataCell = row.createCell(5 + questions.size());
            evalDataCell.setCellValue(evaluation);
            evalDataCell.setCellStyle(evaluationStyle);
        }
    }

    private CellStyle createTitleStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 18);
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.CENTER);
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

    private CellStyle createInfoStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setAlignment(HorizontalAlignment.LEFT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    private CellStyle createColumnHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 10);
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.LIGHT_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setWrapText(true);
        return style;
    }

    private CellStyle createCellStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setAlignment(HorizontalAlignment.LEFT);
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
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    private CellStyle createEvaluationStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setAlignment(HorizontalAlignment.LEFT);
        style.setVerticalAlignment(VerticalAlignment.TOP);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setWrapText(true);
        return style;
    }

    private void autoSizeColumns(Sheet sheet, int questionCount) {
        sheet.setColumnWidth(0, 2000);
        sheet.setColumnWidth(1, 3000);
        sheet.setColumnWidth(2, 4000);
        
        for (int i = 0; i < questionCount; i++) {
            sheet.setColumnWidth(3 + i, 2500);
        }
        
        sheet.setColumnWidth(3 + questionCount, 2500);
        sheet.setColumnWidth(4 + questionCount, 2500);
    }
}
