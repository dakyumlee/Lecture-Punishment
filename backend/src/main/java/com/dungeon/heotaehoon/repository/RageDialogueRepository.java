package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.RageDialogue;
import com.dungeon.heotaehoon.entity.Instructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface RageDialogueRepository extends JpaRepository<RageDialogue, UUID> {
    
    List<RageDialogue> findByInstructor(Instructor instructor);
    
    List<RageDialogue> findByDialogueType(String dialogueType);
    
    List<RageDialogue> findByInstructorAndDialogueType(Instructor instructor, String dialogueType);
    
    @Query("SELECT rd FROM RageDialogue rd WHERE rd.instructor = :instructor AND rd.dialogueType = :dialogueType ORDER BY RANDOM() LIMIT 1")
    RageDialogue findRandomByInstructorAndDialogueType(Instructor instructor, String dialogueType);
}
