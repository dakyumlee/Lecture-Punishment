package com.dungeon.heotaehoon.controller;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.StudentGroup;
import com.dungeon.heotaehoon.service.StudentGroupService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/groups")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class StudentGroupController {

    private final StudentGroupService groupService;

    @PostMapping
    public ResponseEntity<StudentGroup> createGroup(@RequestBody Map<String, Object> request) {
        String groupName = (String) request.get("groupName");
        Integer year = (Integer) request.get("year");
        String course = (String) request.get("course");
        String period = (String) request.get("period");
        String description = (String) request.get("description");
        
        StudentGroup group = groupService.createGroup(groupName, year, course, period, description);
        return ResponseEntity.ok(group);
    }

    @GetMapping
    public ResponseEntity<List<StudentGroup>> getAllGroups() {
        return ResponseEntity.ok(groupService.getAllActiveGroups());
    }

    @GetMapping("/{groupId}")
    public ResponseEntity<StudentGroup> getGroup(@PathVariable String groupId) {
        return ResponseEntity.ok(groupService.getGroupById(groupId));
    }

    @PutMapping("/{groupId}")
    public ResponseEntity<StudentGroup> updateGroup(
            @PathVariable String groupId,
            @RequestBody Map<String, Object> request) {
        String groupName = (String) request.get("groupName");
        Integer year = (Integer) request.get("year");
        String course = (String) request.get("course");
        String period = (String) request.get("period");
        String description = (String) request.get("description");
        
        StudentGroup group = groupService.updateGroup(groupId, groupName, year, course, period, description);
        return ResponseEntity.ok(group);
    }

    @DeleteMapping("/{groupId}")
    public ResponseEntity<Void> deleteGroup(@PathVariable String groupId) {
        groupService.deleteGroup(groupId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{groupId}/students/{studentId}")
    public ResponseEntity<Student> assignStudent(
            @PathVariable String groupId,
            @PathVariable String studentId) {
        Student student = groupService.assignStudentToGroup(studentId, groupId);
        return ResponseEntity.ok(student);
    }

    @GetMapping("/{groupId}/students")
    public ResponseEntity<List<Student>> getGroupStudents(@PathVariable String groupId) {
        return ResponseEntity.ok(groupService.getStudentsByGroup(groupId));
    }

    @DeleteMapping("/{groupId}/students/{studentId}")
    public ResponseEntity<Void> removeStudent(
            @PathVariable String groupId,
            @PathVariable String studentId) {
        groupService.removeStudentFromGroup(studentId);
        return ResponseEntity.ok().build();
    }
}
