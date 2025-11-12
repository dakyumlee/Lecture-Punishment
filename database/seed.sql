-- 기본 강사 데이터
INSERT INTO instructors (id, name, level, exp, rage_gauge, evolution_stage) 
VALUES ('instructor-001', '허태훈', 1, 0, 0, 'normal')
ON CONFLICT (id) DO NOTHING;

-- 테스트 수업 데이터
INSERT INTO lessons (id, title, subject, created_at) 
VALUES 
    ('lesson-001', '자료구조 기초', '자료구조', CURRENT_DATE),
    ('lesson-002', '알고리즘 입문', '알고리즘', CURRENT_DATE - INTERVAL '1 day')
ON CONFLICT (id) DO NOTHING;

-- 보스 데이터
INSERT INTO bosses (id, lesson_id, name, hp_total, hp_current, is_defeated)
VALUES 
    ('boss-001', 'lesson-001', '자료구조 마왕', 100, 100, false),
    ('boss-002', 'lesson-002', '알고리즘 귀신', 100, 100, false)
ON CONFLICT (id) DO NOTHING;

-- 퀴즈 데이터
INSERT INTO quizzes (id, lesson_id, question, correct_answer, created_at)
VALUES
    ('quiz-001', 'lesson-001', '스택의 LIFO는 무엇의 약자인가?', 'Last In First Out', CURRENT_TIMESTAMP),
    ('quiz-002', 'lesson-001', '큐의 기본 연산 2가지는?', 'enqueue, dequeue', CURRENT_TIMESTAMP),
    ('quiz-003', 'lesson-001', '배열과 리스트의 차이는?', '크기 고정 vs 동적', CURRENT_TIMESTAMP),
    ('quiz-004', 'lesson-002', 'O(n)의 시간복잡도를 가진 정렬 알고리즘은?', '없음', CURRENT_TIMESTAMP),
    ('quiz-005', 'lesson-002', '이진 탐색의 시간복잡도는?', 'O(log n)', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- 상점 아이템 추가
INSERT INTO shop_items (id, item_type, name, description, price, rarity, metadata) VALUES
-- 옷 (outfit)
('item-outfit-001', 'outfit', '기본 교복', '평범한 학생 교복', 0, 'common', '{"color": "#0D0D0D", "style": "default"}'),
('item-outfit-002', 'outfit', '허태훈 티셔츠', '허태훈 강사 팬 티셔츠. 분노 -5%', 100, 'rare', '{"color": "#595048", "style": "casual", "effect": "rage_reduce"}'),
('item-outfit-003', 'outfit', '생존자 자켓', '분노에서 살아남은 자의 증표', 500, 'epic', '{"color": "#00010D", "style": "survivor", "effect": "defense"}'),
('item-outfit-004', 'outfit', '닌자복', '조용히 복습하는 자', 300, 'rare', '{"color": "#2C2C2C", "style": "ninja"}'),
('item-outfit-005', 'outfit', '갑옷', '물리적 분노 차단', 400, 'epic', '{"color": "#736A63", "style": "armor"}'),
('item-outfit-006', 'outfit', '마법사 로브', '지식의 힘을 담은 로브', 600, 'epic', '{"color": "#4B0082", "style": "wizard"}'),
('item-outfit-007', 'outfit', '정장', '프로페셔널 학생', 250, 'rare', '{"color": "#1C1C1C", "style": "suit"}'),

-- 표정 (expression)
('item-expr-001', 'expression', '😐 무표정', '기본 표정', 0, 'common', '{"emoji": "neutral"}'),
('item-expr-002', 'expression', '😭 멘붕', '멘탈 붕괴 표정', 50, 'common', '{"emoji": "crying"}'),
('item-expr-003', 'expression', '😎 자신감', '3연속 정답 후 표정', 150, 'rare', '{"emoji": "confident"}'),
('item-expr-004', 'expression', '😈 복수', '허태훈을 이긴 표정', 300, 'epic', '{"emoji": "revenge"}'),
('item-expr-005', 'expression', '😊 행복', '만족스러운 표정', 80, 'common', '{"emoji": "happy"}'),
('item-expr-006', 'expression', '😤 분노', '역분노 표정', 200, 'rare', '{"emoji": "angry"}'),
('item-expr-007', 'expression', '🤓 천재', '모든 문제 정답 표정', 400, 'epic', '{"emoji": "genius"}'),
('item-expr-008', 'expression', '😱 공포', '허태훈 등장 시', 100, 'common', '{"emoji": "scared"}'),
('item-expr-009', 'expression', '😴 졸림', '밤샘 공부의 흔적', 120, 'rare', '{"emoji": "sleepy"}'),
('item-expr-010', 'expression', '🥳 축하', '레벨업 표정', 250, 'rare', '{"emoji": "party"}'),

-- 버프 (buff)
('item-buff-001', 'buff', '🛡️ 분노 내성', '분노 데미지 50% 감소 (1시간)', 200, 'rare', '{"duration": 3600, "effect": "rage_resistance", "value": 0.5}'),
('item-buff-002', 'buff', '⚡ 경험치 부스트', 'EXP 2배 획득 (1시간)', 300, 'epic', '{"duration": 3600, "effect": "exp_boost", "value": 2.0}'),
('item-buff-003', 'buff', '💰 포인트 2배', '포인트 2배 획득 (1시간)', 350, 'epic', '{"duration": 3600, "effect": "point_boost", "value": 2.0}'),
('item-buff-004', 'buff', '🧠 집중력 향상', '오답률 30% 감소 (30분)', 150, 'rare', '{"duration": 1800, "effect": "accuracy_boost", "value": 0.3}'),
('item-buff-005', 'buff', '⏰ 시간 연장', '답안 작성 시간 2배 (1시간)', 180, 'rare', '{"duration": 3600, "effect": "time_extend", "value": 2.0}'),
('item-buff-006', 'buff', '🔮 행운의 부적', '모든 보상 1.5배 (1시간)', 400, 'epic', '{"duration": 3600, "effect": "lucky_charm", "value": 1.5}'),
('item-buff-007', 'buff', '💪 불굴의 의지', '멘탈 게이지 소모 50% 감소 (1시간)', 250, 'epic', '{"duration": 3600, "effect": "mental_shield", "value": 0.5}'),

-- 소모품 (consumable)
('item-cons-001', 'consumable', '💊 멘탈 회복약', '멘탈 게이지 +50', 100, 'common', '{"heal": 50, "type": "mental"}'),
('item-cons-002', 'consumable', '☕ 커피', 'EXP +10, 멘탈 +10', 50, 'common', '{"exp": 10, "mental": 10}'),
('item-cons-003', 'consumable', '🍕 피자 한 판', 'HP +30, 멘탈 +30', 150, 'rare', '{"hp": 30, "mental": 30}'),
('item-cons-004', 'consumable', '📚 치트시트', '다음 문제 정답 힌트', 200, 'rare', '{"effect": "hint"}'),
('item-cons-005', 'consumable', '🎯 정답권', '다음 문제 자동 정답', 500, 'epic', '{"effect": "auto_correct"}'),
('item-cons-006', 'consumable', '💎 완전 회복약', '멘탈 게이지 100% 회복', 300, 'epic', '{"heal": 100, "type": "mental"}'),
('item-cons-007', 'consumable', '🍜 라면', 'EXP +20, 멘탈 +20', 80, 'common', '{"exp": 20, "mental": 20}'),
('item-cons-008', 'consumable', '🧃 에너지 드링크', 'EXP +30, 버프 10분', 120, 'rare', '{"exp": 30, "buff_duration": 600}'),
('item-cons-009', 'consumable', '🍰 케이크', '멘탈 +40, 행복 버프', 180, 'rare', '{"mental": 40, "buff": "happiness"}'),
('item-cons-010', 'consumable', '🎁 랜덤 박스', '랜덤 보상 획득', 250, 'epic', '{"effect": "random_reward"}'),

-- 특별 아이템
('item-special-001', 'outfit', '👑 왕관', '레전더리 아이템. 모든 능력치 +10%', 1000, 'legendary', '{"effect": "all_stats_boost", "value": 0.1}'),
('item-special-002', 'expression', '😇 깨달음', '허태훈도 인정한 표정', 800, 'legendary', '{"emoji": "enlightened", "effect": "master"}'),
('item-special-003', 'buff', '🌟 무적 모드', '1회 오답 무효화 (1시간)', 600, 'legendary', '{"duration": 3600, "effect": "invincible"}'),
('item-special-004', 'consumable', '🔥 허태훈 진정제', '분노 게이지 완전 초기화', 999, 'legendary', '{"effect": "rage_reset"}')
ON CONFLICT (id) DO NOTHING;
