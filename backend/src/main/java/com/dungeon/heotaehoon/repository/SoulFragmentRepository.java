package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.SoulFragment;
import com.dungeon.heotaehoon.entity.Student;
import com.dungeon.heotaehoon.entity.MultiverseInstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SoulFragmentRepository extends JpaRepository<SoulFragment, String> {
    List<SoulFragment> findByStudent(Student student);
    Optional<SoulFragment> findByStudentAndMultiverseInstructor(Student student, MultiverseInstructor multiverseInstructor);
    long countByStudent(Student student);
}
