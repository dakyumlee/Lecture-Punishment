package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.ExpLog;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.Instructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ExpLogRepository extends JpaRepository<ExpLog, UUID> {
    
    List<ExpLog> findByStudent(Student student);
    
    List<ExpLog> findByInstructor(Instructor instructor);
    
    List<ExpLog> findByExpType(String expType);
}
