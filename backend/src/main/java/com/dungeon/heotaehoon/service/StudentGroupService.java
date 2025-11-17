package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.StudentGroup;
import com.dungeon.heotaehoon.repository.StudentGroupRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class StudentGroupService {

    private final StudentGroupRepository studentGroupRepository;

    public List<StudentGroup> getAllGroups() {
        return studentGroupRepository.findAll();
    }

    public List<StudentGroup> getActiveGroups() {
        return studentGroupRepository.findByIsActiveTrue();
    }

    public StudentGroup getGroupById(String id) {
        return studentGroupRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("그룹을 찾을 수 없습니다: " + id));
    }

    @Transactional
    public StudentGroup createGroup(String groupName, Integer year, String course, String period, String description) {
        StudentGroup group = StudentGroup.builder()
                .groupName(groupName)
                .year(year)
                .course(course)
                .period(period)
                .description(description)
                .isActive(true)
                .createdAt(LocalDateTime.now())
                .build();
        
        log.info("Creating group: {}", groupName);
        return studentGroupRepository.save(group);
    }

    @Transactional
    public StudentGroup updateGroup(String id, String groupName, Integer year, String course, String period, String description) {
        StudentGroup group = getGroupById(id);
        
        if (groupName != null) group.setGroupName(groupName);
        if (year != null) group.setYear(year);
        if (course != null) group.setCourse(course);
        if (period != null) group.setPeriod(period);
        if (description != null) group.setDescription(description);
        
        log.info("Updating group: {}", id);
        return studentGroupRepository.save(group);
    }

    @Transactional
    public void deleteGroup(String id) {
        StudentGroup group = getGroupById(id);
        group.setIsActive(false);
        studentGroupRepository.save(group);
        log.info("Deactivated group: {}", id);
    }

    @Transactional
    public void permanentlyDeleteGroup(String id) {
        studentGroupRepository.deleteById(id);
        log.info("Permanently deleted group: {}", id);
    }
}
