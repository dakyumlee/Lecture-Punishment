package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.StudentGroup;
import com.dungeon.heotaehoon.repository.StudentGroupRepository;
import com.dungeon.heotaehoon.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class StudentGroupService {

    private final StudentGroupRepository groupRepository;
    private final StudentRepository studentRepository;

    public List<StudentGroup> getAllGroups() {
        return groupRepository.findAll();
    }

    public StudentGroup getGroupById(String id) {
        return groupRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("그룹을 찾을 수 없습니다"));
    }

    @Transactional
    public StudentGroup createGroup(StudentGroup group) {
        group.setCreatedAt(LocalDateTime.now());
        return groupRepository.save(group);
    }

    @Transactional
    public StudentGroup updateGroup(String id, StudentGroup groupDetails) {
        StudentGroup group = getGroupById(id);
        group.setGroupName(groupDetails.getGroupName());
        group.setDescription(groupDetails.getDescription());
        return groupRepository.save(group);
    }

    @Transactional
    public void deleteGroup(String id) {
        StudentGroup group = getGroupById(id);
        List<Student> students = studentRepository.findByGroup(group);
        students.forEach(student -> student.setGroup(null));
        studentRepository.saveAll(students);
        groupRepository.delete(group);
    }

    @Transactional
    public void addStudentToGroup(String groupId, String studentId) {
        StudentGroup group = getGroupById(groupId);
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
        student.setGroup(group);
        studentRepository.save(student);
    }

    @Transactional
    public void removeStudentFromGroup(String groupId, String studentId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
        
        if (student.getGroup() != null && student.getGroup().getId().equals(groupId)) {
            student.setGroup(null);
            studentRepository.save(student);
        }
    }

    public List<Student> getStudentsByGroup(String groupId) {
        StudentGroup group = getGroupById(groupId);
        return studentRepository.findByGroup(group);
    }
}
