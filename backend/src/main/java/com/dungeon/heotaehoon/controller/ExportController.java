package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.StudentGroup;
import com.dungeon.heotaehoon.repository.StudentGroupRepository;
import com.dungeon.heotaehoon.service.ExcelExportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@RestController
@RequestMapping("/api/export")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ExportController {

    private final ExcelExportService excelExportService;
    private final StudentGroupRepository groupRepository;

    @GetMapping("/group/{groupId}/excel")
    public ResponseEntity<byte[]> exportGroupScores(@PathVariable Long groupId) {
        try {
            StudentGroup group = groupRepository.findById(groupId)
                    .orElseThrow(() -> new RuntimeException("그룹을 찾을 수 없습니다"));

            String fileName = group.getGroupName() + "_성적표.xlsx";
            byte[] excelData = excelExportService.generateGroupScoreExcel(groupId, group);

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(excelData);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/all/excel")
    public ResponseEntity<byte[]> exportAllScores() {
        try {
            String fileName = "전체_성적표.xlsx";
            byte[] excelData = excelExportService.generateAllStudentsScoreExcel();

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(excelData);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/worksheet/{worksheetId}/excel")
    public ResponseEntity<byte[]> exportWorksheetResult(@PathVariable Long worksheetId) {
        try {
            String fileName = "학습지_" + worksheetId + "_결과.xlsx";
            byte[] excelData = excelExportService.generateWorksheetResultExcel(worksheetId);

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(excelData);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
