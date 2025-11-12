CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    level INTEGER DEFAULT 1,
    exp INTEGER DEFAULT 0,
    points INTEGER DEFAULT 0,
    total_correct INTEGER DEFAULT 0,
    total_wrong INTEGER DEFAULT 0,
    mental_gauge INTEGER DEFAULT 100,
    character_outfit VARCHAR(50) DEFAULT 'default',
    character_expression VARCHAR(50) DEFAULT 'neutral',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE instructors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    level INTEGER DEFAULT 1,
    exp INTEGER DEFAULT 0,
    rage_gauge INTEGER DEFAULT 0,
    evolution_stage VARCHAR(50) DEFAULT 'angry',
    voice_model_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    instructor_id UUID REFERENCES instructors(id),
    title VARCHAR(200) NOT NULL,
    subject VARCHAR(100) NOT NULL,
    difficulty_stars INTEGER DEFAULT 3,
    is_active BOOLEAN DEFAULT true,
    lesson_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE bosses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id UUID REFERENCES lessons(id),
    boss_name VARCHAR(100) NOT NULL,
    boss_subtitle VARCHAR(200),
    total_hp INTEGER DEFAULT 1000,
    current_hp INTEGER DEFAULT 1000,
    is_defeated BOOLEAN DEFAULT false,
    defeat_reward_exp INTEGER DEFAULT 100,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE quizzes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id UUID REFERENCES lessons(id),
    boss_id UUID REFERENCES bosses(id),
    question_text TEXT NOT NULL,
    option_a TEXT NOT NULL,
    option_b TEXT NOT NULL,
    option_c TEXT NOT NULL,
    option_d TEXT NOT NULL,
    correct_answer CHAR(1) NOT NULL,
    exp_reward INTEGER DEFAULT 10,
    difficulty INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES students(id),
    quiz_id UUID REFERENCES quizzes(id),
    selected_answer CHAR(1) NOT NULL,
    is_correct BOOLEAN NOT NULL,
    attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    rage_triggered BOOLEAN DEFAULT false,
    combo_count INTEGER DEFAULT 0
);

CREATE TABLE exp_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES students(id),
    instructor_id UUID REFERENCES instructors(id),
    exp_amount INTEGER NOT NULL,
    exp_type VARCHAR(50) NOT NULL,
    source_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE rage_dialogues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    instructor_id UUID REFERENCES instructors(id),
    dialogue_text TEXT NOT NULL,
    dialogue_type VARCHAR(50) NOT NULL,
    intensity_level INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE multiverse_worlds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    world_name VARCHAR(100) NOT NULL,
    world_subtitle VARCHAR(200),
    instructor_variant VARCHAR(100) NOT NULL,
    teaching_style VARCHAR(100) NOT NULL,
    background_color VARCHAR(7) NOT NULL,
    is_unlocked BOOLEAN DEFAULT false,
    unlock_requirement_exp INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE student_inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES students(id),
    item_type VARCHAR(50) NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    item_data JSONB,
    acquired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE class_rankings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id UUID REFERENCES lessons(id),
    student_id UUID REFERENCES students(id),
    rank INTEGER NOT NULL,
    total_score INTEGER NOT NULL,
    accuracy_rate DECIMAL(5,2),
    has_rage_resistance BOOLEAN DEFAULT false,
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raid_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    boss_id UUID REFERENCES bosses(id),
    session_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    session_end TIMESTAMP,
    total_participants INTEGER DEFAULT 0,
    success BOOLEAN DEFAULT false,
    collective_rage INTEGER DEFAULT 0
);

CREATE TABLE mental_recovery_missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES students(id),
    mission_type VARCHAR(50) NOT NULL,
    mission_data JSONB,
    is_completed BOOLEAN DEFAULT false,
    mental_recovered INTEGER DEFAULT 0,
    completed_at TIMESTAMP
);

CREATE INDEX idx_students_username ON students(username);
CREATE INDEX idx_quiz_attempts_student ON quiz_attempts(student_id);
CREATE INDEX idx_quiz_attempts_quiz ON quiz_attempts(quiz_id);
CREATE INDEX idx_exp_logs_student ON exp_logs(student_id);
CREATE INDEX idx_exp_logs_instructor ON exp_logs(instructor_id);
CREATE INDEX idx_lessons_date ON lessons(lesson_date);
CREATE INDEX idx_class_rankings_lesson ON class_rankings(lesson_id);
CREATE INDEX idx_rage_dialogues_instructor ON rage_dialogues(instructor_id);

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER students_updated_at
    BEFORE UPDATE ON students
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER instructors_updated_at
    BEFORE UPDATE ON instructors
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TABLE pdf_worksheets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    instructor_id UUID REFERENCES instructors(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    subject VARCHAR(100) NOT NULL,
    category VARCHAR(100) NOT NULL,
    difficulty_level INTEGER DEFAULT 1,
    pdf_url VARCHAR(500),
    total_questions INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE worksheet_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    worksheet_id UUID REFERENCES pdf_worksheets(id) ON DELETE CASCADE,
    question_number INTEGER NOT NULL,
    question_type VARCHAR(20) NOT NULL,
    question_text TEXT NOT NULL,
    correct_answer TEXT NOT NULL,
    option_a TEXT,
    option_b TEXT,
    option_c TEXT,
    option_d TEXT,
    points INTEGER DEFAULT 10,
    allow_partial BOOLEAN DEFAULT false,
    similarity_threshold DECIMAL(3,2) DEFAULT 0.85,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE student_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES students(id),
    worksheet_id UUID REFERENCES pdf_worksheets(id),
    submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_score INTEGER DEFAULT 0,
    max_score INTEGER DEFAULT 0,
    percentage DECIMAL(5,2) DEFAULT 0,
    is_graded BOOLEAN DEFAULT false,
    graded_at TIMESTAMP
);

CREATE TABLE submission_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    submission_id UUID REFERENCES student_submissions(id) ON DELETE CASCADE,
    question_id UUID REFERENCES worksheet_questions(id),
    student_answer TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT false,
    points_earned INTEGER DEFAULT 0,
    similarity_score DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE worksheet_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    parent_category_id UUID REFERENCES worksheet_categories(id),
    description TEXT,
    color VARCHAR(7) DEFAULT '#595048',
    icon VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pdf_worksheets_instructor ON pdf_worksheets(instructor_id);
CREATE INDEX idx_pdf_worksheets_category ON pdf_worksheets(category);
CREATE INDEX idx_worksheet_questions_worksheet ON worksheet_questions(worksheet_id);
CREATE INDEX idx_student_submissions_student ON student_submissions(student_id);
CREATE INDEX idx_student_submissions_worksheet ON student_submissions(worksheet_id);
CREATE INDEX idx_submission_answers_submission ON submission_answers(submission_id);

CREATE TRIGGER pdf_worksheets_updated_at
    BEFORE UPDATE ON pdf_worksheets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TABLE shop_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_type VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price INTEGER NOT NULL,
    rarity VARCHAR(20) DEFAULT 'common',
    image_url VARCHAR(255),
    is_available BOOLEAN DEFAULT true,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_shop_items_type ON shop_items(item_type);
CREATE INDEX idx_shop_items_available ON shop_items(is_available);

INSERT INTO shop_items (item_type, name, description, price, rarity, metadata) VALUES
('outfit', '기본 교복', '평범한 교복', 0, 'common', '{"color": "#0D0D0D", "style": "default"}'),
('outfit', '허태훈 티셔츠', '허태훈 강사 팬 티셔츠', 100, 'rare', '{"color": "#595048", "style": "casual"}'),
('outfit', '생존자 자켓', '분노에서 살아남은 자의 증표', 500, 'epic', '{"color": "#00010D", "style": "survivor"}'),
('expression', '😐 무표정', '기본 표정', 0, 'common', '{"emoji": "neutral"}'),
('expression', '😭 멘붕', '멘탈 붕괴 표정', 50, 'common', '{"emoji": "crying"}'),
('expression', '😎 자신감', '3연속 정답 표정', 150, 'rare', '{"emoji": "confident"}'),
('expression', '😈 복수', '허태훈을 이긴 표정', 300, 'epic', '{"emoji": "revenge"}'),
('buff', '🛡️ 분노 내성', '분노 데미지 50% 감소 (1시간)', 200, 'rare', '{"duration": 3600, "effect": "rage_resistance"}'),
('buff', '⚡ 경험치 부스트', 'EXP 2배 획득 (1시간)', 300, 'epic', '{"duration": 3600, "effect": "exp_boost"}'),
('consumable', '💊 멘탈 회복약', '멘탈 게이지 +50', 100, 'common', '{"heal": 50}')
ON CONFLICT DO NOTHING;
