package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.dto.StudentScoreDto;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.StudentGroup;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ExcelExportService {

    private final StudentRepository studentRepository;

    public byte[] generateGroupScoreExcel(String groupId, StudentGroup group) throws IOException {
        List<Student> students = studentRepository.findByGroup(group);
        
        List<StudentScoreDto> scores = students.stream()
            .map(this::convertToDto)
            .collect(Collectors.toList());

        return createExcelFile(scores, group);
    }

    public byte[] generateAllStudentsScoreExcel() throws IOException {
        List<Student> students = studentRepository.findAll();
        
        List<StudentScoreDto> scores = students.stream()
            .map(this::convertToDto)
            .collect(Collectors.toList());

        return createExcelFile(scores, null);
    }

    private StudentScoreDto convertToDto(Student student) {
        int total = student.getTotalCorrect() + student.getTotalWrong();
        double successRate = total > 0 ? (student.getTotalCorrect() * 100.0 / total) : 0.0;
        
        return StudentScoreDto.builder()
            .studentId(student.getId())
            .studentName(student.getDisplayName())
            .username(student.getUsername())
            .level(student.getLevel())
            .totalCorrect(student.getTotalCorrect())
            .totalWrong(student.getTotalWrong())
            .successRate(successRate)
            .totalScore(student.getExp())
            .groupName(student.getGroup() != null ? student.getGroup().getGroupName() : "-")
            .year(student.getGroup() != null ? student.getGroup().getYear() : null)
            .course(student.getGroup() != null ? student.getGroup().getCourse() : "-")
            .build();
    }

    private byte[] createExcelFile(List<StudentScoreDto> scores, StudentGroup group) throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("성적표");

        CellStyle headerStyle = createHeaderStyle(workbook);
        CellStyle dataStyle = createDataStyle(workbook);

        int rowNum = 0;

        Row titleRow = sheet.createRow(rowNum++);
        Cell titleCell = titleRow.createCell(0);
        if (group != null) {
            titleCell.setCellValue(group.getGroupName() + " 평가 성적현황");
        } else {
            titleCell.setCellValue("전체 학생 평가 성적현황");
        }
        titleCell.setCellStyle(headerStyle);

        rowNum++;

        Row infoRow1 = sheet.createRow(rowNum++);
        infoRow1.createCell(0).setCellValue("교과목명");
        if (group != null) {
            infoRow1.createCell(1).setCellValue(group.getCourse());
        }

        Row infoRow2 = sheet.createRow(rowNum++);
        infoRow2.createCell(0).setCellValue("년도");
        if (group != null) {
            infoRow2.createCell(1).setCellValue(group.getYear() != null ? group.getYear().toString() : "");
        }

        Row infoRow3 = sheet.createRow(rowNum++);
        infoRow3.createCell(0).setCellValue("기간");
        if (group != null) {
            infoRow3.createCell(1).setCellValue(group.getPeriod());
        }

        rowNum++;

        Row headerRow = sheet.createRow(rowNum++);
        String[] headers = {"순번", "학생명", "아이디", "레벨", "정답수", "오답수", "정답률(%)", "총점수(EXP)", "그룹"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }

        for (int i = 0; i < scores.size(); i++) {
            StudentScoreDto score = scores.get(i);
            Row row = sheet.createRow(rowNum++);

            row.createCell(0).setCellValue(i + 1);
            row.createCell(1).setCellValue(score.getStudentName());
            row.createCell(2).setCellValue(score.getUsername());
            row.createCell(3).setCellValue(score.getLevel());
            row.createCell(4).setCellValue(score.getTotalCorrect());
            row.createCell(5).setCellValue(score.getTotalWrong());
            row.createCell(6).setCellValue(String.format("%.1f", score.getSuccessRate()));
            row.createCell(7).setCellValue(score.getTotalScore());
            row.createCell(8).setCellValue(score.getGroupName());

            for (int j = 0; j < 9; j++) {
                row.getCell(j).setCellStyle(dataStyle);
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

    private CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.CENTER);

        Font font = workbook.createFont();
        font.setBold(true);
        style.setFont(font);

        return style;
    }

    private CellStyle createDataStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.CENTER);
        return style;
    }
}
