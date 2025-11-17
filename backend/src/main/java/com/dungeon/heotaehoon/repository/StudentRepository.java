package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.StudentGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, String> {
    Optional<Student> findByUsername(String username);
    Optional<Student> findByDisplayName(String displayName);
    List<Student> findAllByDisplayName(String displayName);
    List<Student> findAllByUsername(String username);
    List<Student> findByGroup(StudentGroup group);
    List<Student> findByGroup_Id(String groupId);
    Optional<Student> findByUsernameAndBirthDate(String username, LocalDate birthDate);
    Optional<Student> findByUsernameAndPhoneNumber(String username, String phoneNumber);
    Optional<Student> findByUsernameAndBirthDateAndPhoneNumber(String username, LocalDate birthDate, String phoneNumber);
    List<Student> findTop10ByOrderByExpDesc();
}
