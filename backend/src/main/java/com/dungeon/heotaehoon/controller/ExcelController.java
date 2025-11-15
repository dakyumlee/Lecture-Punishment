package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.StudentGroup;
import com.dungeon.heotaehoon.service.ExcelExportService;
import com.dungeon.heotaehoon.service.StudentGroupService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@RestController
@RequestMapping("/api/excel")
@RequiredArgsConstructor
public class ExcelController {

    private final ExcelExportService excelExportService;
    private final StudentGroupService groupService;

    @GetMapping("/groups/{groupId}")
    public ResponseEntity<byte[]> downloadGroupExcel(@PathVariable String groupId) {
        try {
            StudentGroup group = groupService.getGroupById(groupId);
            byte[] excelBytes = excelExportService.generateGroupScoreExcel(groupId, group);
            
            String filename = group.getGroupName() + "_성적표.xlsx";
            
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                    .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                    .body(excelBytes);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/students/all")
    public ResponseEntity<byte[]> downloadAllStudentsExcel() {
        try {
            byte[] excelBytes = excelExportService.generateAllStudentsScoreExcel();
            
            String filename = "전체학생_성적표.xlsx";
            
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                    .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                    .body(excelBytes);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/worksheets/{worksheetId}")
    public ResponseEntity<byte[]> downloadWorksheetResultExcel(@PathVariable String worksheetId) {
        try {
            byte[] excelBytes = excelExportService.generateWorksheetResultExcel(worksheetId);
            
            String filename = "문제지_결과.xlsx";
            
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                    .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                    .body(excelBytes);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
