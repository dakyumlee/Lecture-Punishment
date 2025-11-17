package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.StudentGroup;
import com.dungeon.heotaehoon.service.StudentGroupService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@Slf4j
@RestController
@RequestMapping("/api/groups")
@RequiredArgsConstructor
public class StudentGroupController {

    private final StudentGroupService studentGroupService;

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getAllGroups() {
        try {
            List<StudentGroup> groups = studentGroupService.getAllGroups();
            List<Map<String, Object>> response = new ArrayList<>();
            
            for (StudentGroup group : groups) {
                Map<String, Object> groupMap = new HashMap<>();
                groupMap.put("id", group.getId());
                groupMap.put("groupName", group.getGroupName());
                groupMap.put("year", group.getYear());
                groupMap.put("course", group.getCourse());
                groupMap.put("period", group.getPeriod());
                groupMap.put("description", group.getDescription());
                groupMap.put("isActive", group.getIsActive());
                groupMap.put("createdAt", group.getCreatedAt());
                response.add(groupMap);
            }
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to get groups", e);
            return ResponseEntity.status(500).body(new ArrayList<>());
        }
    }

    @GetMapping("/active")
    public ResponseEntity<List<Map<String, Object>>> getActiveGroups() {
        try {
            List<StudentGroup> groups = studentGroupService.getActiveGroups();
            List<Map<String, Object>> response = new ArrayList<>();
            
            for (StudentGroup group : groups) {
                Map<String, Object> groupMap = new HashMap<>();
                groupMap.put("id", group.getId());
                groupMap.put("groupName", group.getGroupName());
                groupMap.put("year", group.getYear());
                groupMap.put("course", group.getCourse());
                groupMap.put("period", group.getPeriod());
                groupMap.put("description", group.getDescription());
                response.add(groupMap);
            }
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to get active groups", e);
            return ResponseEntity.status(500).body(new ArrayList<>());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getGroup(@PathVariable String id) {
        try {
            StudentGroup group = studentGroupService.getGroupById(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("id", group.getId());
            response.put("groupName", group.getGroupName());
            response.put("year", group.getYear());
            response.put("course", group.getCourse());
            response.put("period", group.getPeriod());
            response.put("description", group.getDescription());
            response.put("isActive", group.getIsActive());
            response.put("createdAt", group.getCreatedAt());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to get group: {}", id, e);
            return ResponseEntity.status(404).body(new HashMap<>());
        }
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createGroup(@RequestBody Map<String, Object> request) {
        try {
            String groupName = (String) request.get("groupName");
            Integer year = request.get("year") != null ? (Integer) request.get("year") : null;
            String course = (String) request.get("course");
            String period = (String) request.get("period");
            String description = (String) request.get("description");
            
            StudentGroup group = studentGroupService.createGroup(groupName, year, course, period, description);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("groupId", group.getId());
            response.put("message", "그룹이 생성되었습니다");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to create group", e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateGroup(
            @PathVariable String id,
            @RequestBody Map<String, Object> request) {
        try {
            String groupName = (String) request.get("groupName");
            Integer year = request.get("year") != null ? (Integer) request.get("year") : null;
            String course = (String) request.get("course");
            String period = (String) request.get("period");
            String description = (String) request.get("description");
            
            studentGroupService.updateGroup(id, groupName, year, course, period, description);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "그룹이 수정되었습니다");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to update group: {}", id, e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteGroup(@PathVariable String id) {
        try {
            studentGroupService.deleteGroup(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "그룹이 비활성화되었습니다");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to delete group: {}", id, e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }
}
