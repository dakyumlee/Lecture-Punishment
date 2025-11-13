package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ExcelExportService {

    private final StudentSubmissionRepository submissionRepository;
    private final SubmissionAnswerRepository submissionAnswerRepository;
    private final StudentRepository studentRepository;
    private final WorksheetQuestionRepository questionRepository;

    public byte[] generateGroupScoreExcel(String groupId, StudentGroup group) throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("성적표");

        CellStyle headerStyle = createHeaderStyle(workbook);
        CellStyle dataStyle = createDataStyle(workbook);

        List<Student> students = studentRepository.findByGroup(group);

        int rowNum = 0;
        Row headerRow = sheet.createRow(rowNum++);
        String[] headers = {"학생명", "아이디", "제출일시", "총점", "정답수", "오답수", "정답률"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }

        for (Student student : students) {
            List<StudentSubmission> submissions = submissionRepository.findByStudent(student);
            for (StudentSubmission submission : submissions) {
                Row row = sheet.createRow(rowNum++);
                
                List<SubmissionAnswer> answers = submissionAnswerRepository.findBySubmission(submission);
                long correctCount = answers.stream().filter(SubmissionAnswer::getIsCorrect).count();
                long totalCount = answers.size();
                double accuracy = totalCount > 0 ? (correctCount * 100.0 / totalCount) : 0.0;

                row.createCell(0).setCellValue(student.getDisplayName());
                row.createCell(1).setCellValue(student.getUsername());
                row.createCell(2).setCellValue(submission.getSubmittedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                row.createCell(3).setCellValue(submission.getTotalScore() != null ? submission.getTotalScore() : 0);
                row.createCell(4).setCellValue(correctCount);
                row.createCell(5).setCellValue(totalCount - correctCount);
                row.createCell(6).setCellValue(String.format("%.1f%%", accuracy));

                for (int i = 0; i < 7; i++) {
                    row.getCell(i).setCellStyle(dataStyle);
                }
            }
        }

        for (int i = 0; i < headers.length; i++) {
            sheet.autoSizeColumn(i);
        }

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();

        return outputStream.toByteArray();
    }

    public byte[] generateAllStudentsScoreExcel() throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("전체 성적표");

        CellStyle headerStyle = createHeaderStyle(workbook);
        CellStyle dataStyle = createDataStyle(workbook);

        List<Student> students = studentRepository.findAll();

        int rowNum = 0;
        Row headerRow = sheet.createRow(rowNum++);
        String[] headers = {"그룹", "학생명", "아이디", "제출일시", "총점", "정답수", "오답수", "정답률"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }

        for (Student student : students) {
            List<StudentSubmission> submissions = submissionRepository.findByStudent(student);
            for (StudentSubmission submission : submissions) {
                Row row = sheet.createRow(rowNum++);
                
                List<SubmissionAnswer> answers = submissionAnswerRepository.findBySubmission(submission);
                long correctCount = answers.stream().filter(SubmissionAnswer::getIsCorrect).count();
                long totalCount = answers.size();
                double accuracy = totalCount > 0 ? (correctCount * 100.0 / totalCount) : 0.0;

                row.createCell(0).setCellValue(student.getGroup() != null ? student.getGroup().getGroupName() : "미배정");
                row.createCell(1).setCellValue(student.getDisplayName());
                row.createCell(2).setCellValue(student.getUsername());
                row.createCell(3).setCellValue(submission.getSubmittedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                row.createCell(4).setCellValue(submission.getTotalScore() != null ? submission.getTotalScore() : 0);
                row.createCell(5).setCellValue(correctCount);
                row.createCell(6).setCellValue(totalCount - correctCount);
                row.createCell(7).setCellValue(String.format("%.1f%%", accuracy));

                for (int i = 0; i < 8; i++) {
                    row.getCell(i).setCellStyle(dataStyle);
                }
            }
        }

        for (int i = 0; i < headers.length; i++) {
            sheet.autoSizeColumn(i);
        }

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();

        return outputStream.toByteArray();
    }

    public byte[] generateWorksheetResultExcel(String worksheetId) throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("학습지 결과");

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
            headerRow.getCell(i).setCellStyle(headerStyle);
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
                row.getCell(i).setCellStyle(dataStyle);
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

    private CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 12);
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
}
