package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, String> {
    Optional<Student> findByUsername(String username);
    List<Student> findAllByUsername(String username);
    Optional<Student> findByUsernameAndBirthDate(String username, LocalDate birthDate);
    Optional<Student> findByUsernameAndPhoneNumber(String username, String phoneNumber);
    Optional<Student> findByUsernameAndBirthDateAndPhoneNumber(String username, LocalDate birthDate, String phoneNumber);
    List<Student> findTop10ByOrderByExpDesc();
}
