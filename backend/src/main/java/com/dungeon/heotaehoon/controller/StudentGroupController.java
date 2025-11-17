
    private final StudentRepository studentRepository;

    @GetMapping("/{groupId}/students")
    public ResponseEntity<List<Map<String, Object>>> getGroupStudents(@PathVariable String groupId) {
        try {
            List<Student> students = studentRepository.findByGroup_Id(groupId);
            List<Map<String, Object>> response = new ArrayList<>();
            
            for (Student student : students) {
                Map<String, Object> studentMap = new HashMap<>();
                studentMap.put("id", student.getId());
                studentMap.put("username", student.getUsername());
                studentMap.put("displayName", student.getDisplayName());
                studentMap.put("level", student.getLevel());
                studentMap.put("exp", student.getExp());
                response.add(studentMap);
            }
            
            log.info("Found {} students in group {}", students.size(), groupId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to get students for group: {}", groupId, e);
            return ResponseEntity.status(500).body(new ArrayList<>());
        }
    }

    @PostMapping("/{groupId}/students/{studentId}")
    public ResponseEntity<Map<String, Object>> addStudentToGroup(
            @PathVariable String groupId,
            @PathVariable String studentId) {
        try {
            StudentGroup group = studentGroupService.getGroupById(groupId);
            Student student = studentRepository.findById(studentId)
                    .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
            
            student.setGroup(group);
            studentRepository.save(student);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "학생이 그룹에 추가되었습니다");
            
            log.info("Added student {} to group {}", studentId, groupId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to add student to group", e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    @DeleteMapping("/{groupId}/students/{studentId}")
    public ResponseEntity<Map<String, Object>> removeStudentFromGroup(
            @PathVariable String groupId,
            @PathVariable String studentId) {
        try {
            Student student = studentRepository.findById(studentId)
                    .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다"));
            
            student.setGroup(null);
            studentRepository.save(student);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "학생이 그룹에서 제거되었습니다");
            
            log.info("Removed student {} from group {}", studentId, groupId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Failed to remove student from group", e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }