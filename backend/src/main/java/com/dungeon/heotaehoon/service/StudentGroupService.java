package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.StudentGroup;
import com.dungeon.heotaehoon.repository.StudentGroupRepository;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class StudentGroupService {

    private final StudentGroupRepository groupRepository;
    private final StudentRepository studentRepository;

    public StudentGroup createGroup(String groupName, Integer year, String course, String period, String description) {
        StudentGroup group = StudentGroup.builder()
            .groupName(groupName)
            .year(year)
            .course(course)
            .period(period)
            .description(description)
            .build();
        
        return groupRepository.save(group);
    }

    public List<StudentGroup> getAllActiveGroups() {
        return groupRepository.findByIsActiveTrue();
    }

    public StudentGroup getGroupById(String groupId) {
        return groupRepository.findById(groupId)
            .orElseThrow(() -> new RuntimeException("Group not found"));
    }

    public void deleteGroup(String groupId) {
        StudentGroup group = getGroupById(groupId);
        group.setIsActive(false);
        groupRepository.save(group);
    }

    public Student assignStudentToGroup(String studentId, String groupId) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("Student not found"));
        
        StudentGroup group = groupRepository.findById(groupId)
            .orElseThrow(() -> new RuntimeException("Group not found"));
        
        student.setGroup(group);
        return studentRepository.save(student);
    }

    public List<Student> getStudentsByGroup(String groupId) {
        StudentGroup group = getGroupById(groupId);
        return studentRepository.findByGroup(group);
    }

    public StudentGroup updateGroup(String groupId, String groupName, Integer year, String course, String period, String description) {
        StudentGroup group = getGroupById(groupId);
        
        if (groupName != null) group.setGroupName(groupName);
        if (year != null) group.setYear(year);
        if (course != null) group.setCourse(course);
        if (period != null) group.setPeriod(period);
        if (description != null) group.setDescription(description);
        
        return groupRepository.save(group);
    }
}
