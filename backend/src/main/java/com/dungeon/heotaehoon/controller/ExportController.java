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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@RestController
@RequestMapping("/api/export")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ExportController {

    private final ExcelExportService excelExportService;
    private final StudentGroupService groupService;

    @GetMapping("/group/{groupId}/excel")
    public ResponseEntity<byte[]> exportGroupExcel(@PathVariable String groupId) throws IOException {
        StudentGroup group = groupService.getGroupById(groupId);
        byte[] excelData = excelExportService.generateGroupScoreExcel(groupId, group);

        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String filename = String.format("%s_성적표_%s.xlsx", 
            group.getGroupName(), timestamp);
        String encodedFilename = URLEncoder.encode(filename, StandardCharsets.UTF_8).replace("+", "%20");

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", encodedFilename);

        return ResponseEntity.ok()
            .headers(headers)
            .body(excelData);
    }

    @GetMapping("/all/excel")
    public ResponseEntity<byte[]> exportAllStudentsExcel() throws IOException {
        byte[] excelData = excelExportService.generateAllStudentsScoreExcel();

        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String filename = String.format("전체학생_성적표_%s.xlsx", timestamp);
        String encodedFilename = URLEncoder.encode(filename, StandardCharsets.UTF_8).replace("+", "%20");

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", encodedFilename);

        return ResponseEntity.ok()
            .headers(headers)
            .body(excelData);
    }
}
