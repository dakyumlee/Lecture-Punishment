package com.dungeon.heotaehoon.config;

import com.dungeon.heotaehoon.entity.*;
import com.dungeon.heotaehoon.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final ShopItemRepository shopItemRepository;
    private final InstructorRepository instructorRepository;
    private final MentalRecoveryMissionRepository mentalRecoveryMissionRepository;
    private final RaidBossRepository raidBossRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        initializeInstructor();
        shopItemRepository.deleteAll();
        createShopItems();
        mentalRecoveryMissionRepository.deleteAll();
        createMentalRecoveryMissions();
        raidBossRepository.deleteAll();
        createRaidBosses();
    }

    private void initializeInstructor() {
        instructorRepository.findByUsername("hth422").ifPresentOrElse(
            instructor -> {
                instructor.setPassword(passwordEncoder.encode("password1234!"));
                if (instructor.getCurrentTitle() == null || instructor.getCurrentTitle().isEmpty()) {
                    instructor.setCurrentTitle("Lv." + instructor.getLevel() + " — 신입 강사");
                }
                instructorRepository.save(instructor);
                System.out.println("✅ 허태훈 강사 비밀번호 업데이트 완료!");
            },
            () -> {
                Instructor instructor = Instructor.builder()
                        .name("허태훈")
                        .username("hth422")
                        .password(passwordEncoder.encode("password1234!"))
                        .level(1)
                        .exp(0)
                        .currentTitle("Lv.1 — 신입 강사")
                        .rageGauge(50)
                        .isEvolved(false)
                        .evolutionStage("normal")
                        .build();
                
                instructorRepository.save(instructor);
                System.out.println("✅ 허태훈 강사 계정 초기화 완료!");
            }
        );
        System.out.println("   아이디: hth422");
        System.out.println("   비밀번호: password1234!");
    }

    private void createRaidBosses() {
        raidBossRepository.save(RaidBoss.builder()
            .bossName("최종 보스: 허태훈의 분노")
            .description("모든 던전을 정복한 자만이 도전할 수 있는 최강의 보스")
            .totalHp(10000)
            .currentHp(10000)
            .minParticipants(3)
            .timeLimitMinutes(30)
            .damagePerCorrect(200)
            .rewardExp(100)
            .rewardPoints(500)
            .penaltyDescription("실패 시 전원 과제 3배")
            .isActive(true)
            .isDefeated(false)
            .build());

        raidBossRepository.save(RaidBoss.builder()
            .bossName("중간 보스: 지식의 수호자")
            .description("지식을 시험하는 중간 난이도 레이드")
            .totalHp(5000)
            .currentHp(5000)
            .minParticipants(2)
            .timeLimitMinutes(20)
            .damagePerCorrect(150)
            .rewardExp(50)
            .rewardPoints(250)
            .penaltyDescription("실패 시 전원 과제 2배")
            .isActive(true)
            .isDefeated(false)
            .build());

        raidBossRepository.save(RaidBoss.builder()
            .bossName("입문 보스: 협동의 시작")
            .description("레이드를 처음 시작하는 초보자용")
            .totalHp(3000)
            .currentHp(3000)
            .minParticipants(2)
            .timeLimitMinutes(15)
            .damagePerCorrect(100)
            .rewardExp(30)
            .rewardPoints(150)
            .penaltyDescription("실패 시 전원 복습 필수")
            .isActive(true)
            .isDefeated(false)
            .build());

        System.out.println("✅ 레이드 보스 초기화 완료!");
    }

    private void createMentalRecoveryMissions() {
        mentalRecoveryMissionRepository.save(MentalRecoveryMission.builder()
            .missionType("word_quiz")
            .title("단어 퀴즈: 사과")
            .description("영어로 사과를 뭐라고 할까요?")
            .questionText("영어로 '사과'를 뭐라고 할까요?")
            .correctAnswer("apple")
            .recoveryAmount(15)
            .difficultyLevel(1)
            .isActive(true)
            .build());

        mentalRecoveryMissionRepository.save(MentalRecoveryMission.builder()
            .missionType("word_quiz")
            .title("단어 퀴즈: 고양이")
            .description("영어로 고양이를 뭐라고 할까요?")
            .questionText("영어로 '고양이'를 뭐라고 할까요?")
            .correctAnswer("cat")
            .recoveryAmount(15)
            .difficultyLevel(1)
            .isActive(true)
            .build());

        mentalRecoveryMissionRepository.save(MentalRecoveryMission.builder()
            .missionType("word_quiz")
            .title("단어 퀴즈: 안녕")
            .description("영어로 안녕을 뭐라고 할까요?")
            .questionText("영어로 '안녕'을 뭐라고 할까요?")
            .correctAnswer("hello")
            .recoveryAmount(15)
            .difficultyLevel(1)
            .isActive(true)
            .build());

        mentalRecoveryMissionRepository.save(MentalRecoveryMission.builder()
            .missionType("word_quiz")
            .title("단어 퀴즈: 물")
            .description("영어로 물을 뭐라고 할까요?")
            .questionText("영어로 '물'을 뭐라고 할까요?")
            .correctAnswer("water")
            .recoveryAmount(15)
            .difficultyLevel(1)
            .isActive(true)
            .build());

        mentalRecoveryMissionRepository.save(MentalRecoveryMission.builder()
            .missionType("word_quiz")
            .title("단어 퀴즈: 책")
            .description("영어로 책을 뭐라고 할까요?")
            .questionText("영어로 '책'을 뭐라고 할까요?")
            .correctAnswer("book")
            .recoveryAmount(15)
            .difficultyLevel(1)
            .isActive(true)
            .build());

        mentalRecoveryMissionRepository.save(MentalRecoveryMission.builder()
            .missionType("self_praise")
            .title("셀프 칭찬하기")
            .description("자신을 칭찬하는 긍정적인 문장을 10자 이상 작성해보세요")
            .questionText("오늘 나 자신에게 해주고 싶은 칭찬을 적어보세요 (최소 10자)")
            .recoveryAmount(20)
            .difficultyLevel(1)
            .isActive(true)
            .build());

        mentalRecoveryMissionRepository.save(MentalRecoveryMission.builder()
            .missionType("self_praise")
            .title("긍정 확언")
            .description("나는 할 수 있다는 마음가짐을 갖고 긍정적인 다짐을 적어보세요")
            .questionText("나는 반드시 __________할 수 있다! (빈칸 채우기)")
            .recoveryAmount(20)
            .difficultyLevel(1)
            .isActive(true)
            .build());

        mentalRecoveryMissionRepository.save(MentalRecoveryMission.builder()
            .missionType("meditation")
            .title("심호흡 명상")
            .description("30초간 깊게 숨을 쉬며 마음을 진정시켜보세요")
            .questionText("30초간 눈을 감고 깊게 숨을 들이쉬고 내쉬세요")
            .recoveryAmount(10)
            .difficultyLevel(1)
            .isActive(true)
            .build());

        mentalRecoveryMissionRepository.save(MentalRecoveryMission.builder()
            .missionType("meditation")
            .title("스트레칭 타임")
            .description("잠시 자리에서 일어나 가볍게 스트레칭을 해보세요")
            .questionText("30초간 편안하게 몸을 풀어보세요")
            .recoveryAmount(10)
            .difficultyLevel(1)
            .isActive(true)
            .build());

        System.out.println("✅ 멘탈 회복 미션 초기화 완료!");
    }

    private void createShopItems() {
        shopItemRepository.save(ShopItem.builder()
            .name("기본 교복")
            .description("평범한 학생 교복")
            .itemType("outfit")
            .price(0)
            .rarity("common")
            .imageUrl("👔")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("명품 양복")
            .description("허태훈도 인정한 멋진 양복")
            .itemType("outfit")
            .price(500)
            .rarity("rare")
            .imageUrl("🤵")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("후드티")
            .description("편안한 캐주얼룩")
            .itemType("outfit")
            .price(300)
            .rarity("common")
            .imageUrl("🧥")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("운동복")
            .description("체육시간 필수템")
            .itemType("outfit")
            .price(200)
            .rarity("common")
            .imageUrl("👟")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("수험생 잠바")
            .description("수험생의 상징")
            .itemType("outfit")
            .price(400)
            .rarity("uncommon")
            .imageUrl("🧤")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("코딩 후드티")
            .description("Hello World 프린팅")
            .itemType("outfit")
            .price(350)
            .rarity("uncommon")
            .imageUrl("💻")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("넥타이 정장")
            .description("취업 준비생 필수")
            .itemType("outfit")
            .price(600)
            .rarity("rare")
            .imageUrl("👨‍💼")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("허태훈 코스튬")
            .description("허태훈이 되어보자")
            .itemType("outfit")
            .price(2000)
            .rarity("legendary")
            .imageUrl("👨‍🏫")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("😊 미소")
            .description("기본 표정")
            .itemType("expression")
            .price(0)
            .rarity("common")
            .imageUrl("😊")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("😭 눈물")
            .description("허태훈에게 맞았을 때")
            .itemType("expression")
            .price(100)
            .rarity("common")
            .imageUrl("😭")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("😡 분노")
            .description("역으로 분노하기")
            .itemType("expression")
            .price(300)
            .rarity("uncommon")
            .imageUrl("😡")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("😎 자신감")
            .description("만점 맞았을 때")
            .itemType("expression")
            .price(400)
            .rarity("rare")
            .imageUrl("😎")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("🤯 멘붕")
            .description("시험 망했을 때")
            .itemType("expression")
            .price(200)
            .rarity("common")
            .imageUrl("🤯")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("😤 빡침")
            .description("더 이상 못 참겠어")
            .itemType("expression")
            .price(250)
            .rarity("uncommon")
            .imageUrl("😤")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("🤔 고민")
            .description("어떤 답이 맞지?")
            .itemType("expression")
            .price(150)
            .rarity("common")
            .imageUrl("🤔")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("😴 졸림")
            .description("밤샘 공부의 결과")
            .itemType("expression")
            .price(180)
            .rarity("common")
            .imageUrl("😴")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("🤩 감탄")
            .description("만점이다!")
            .itemType("expression")
            .price(500)
            .rarity("rare")
            .imageUrl("🤩")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("😈 악동")
            .description("장난기 가득")
            .itemType("expression")
            .price(350)
            .rarity("uncommon")
            .imageUrl("😈")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("방어막")
            .description("허태훈의 분노를 1회 막아줌")
            .itemType("consumable")
            .price(1000)
            .rarity("rare")
            .imageUrl("🛡️")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("힌트권")
            .description("퀴즈 힌트 1개 제공")
            .itemType("consumable")
            .price(500)
            .rarity("uncommon")
            .imageUrl("💡")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("부활권")
            .description("틀린 문제를 다시 풀 수 있음")
            .itemType("consumable")
            .price(800)
            .rarity("rare")
            .imageUrl("❤️‍🩹")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("EXP 부스터")
            .description("경험치 2배 (1시간)")
            .itemType("consumable")
            .price(700)
            .rarity("uncommon")
            .imageUrl("⚡")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("포인트 부스터")
            .description("포인트 2배 (1시간)")
            .itemType("consumable")
            .price(600)
            .rarity("uncommon")
            .imageUrl("💰")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("타임 프리즈")
            .description("제한시간 30초 추가")
            .itemType("consumable")
            .price(400)
            .rarity("uncommon")
            .imageUrl("⏰")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("정답 공개권")
            .description("문제 1개의 정답 공개")
            .itemType("consumable")
            .price(1500)
            .rarity("epic")
            .imageUrl("📝")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("분노 감소제")
            .description("허태훈 분노 게이지 -20%")
            .itemType("consumable")
            .price(900)
            .rarity("rare")
            .imageUrl("🧘")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("스킬 북: 집중력")
            .description("정답률 10% 상승 (영구)")
            .itemType("consumable")
            .price(3000)
            .rarity("legendary")
            .imageUrl("📚")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("복습 노트")
            .description("틀린 문제 모아보기")
            .itemType("consumable")
            .price(200)
            .rarity("common")
            .imageUrl("📓")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("행운의 부적")
            .description("랜덤 보상 2배")
            .itemType("consumable")
            .price(1200)
            .rarity("epic")
            .imageUrl("🍀")
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("커피")
            .description("졸음 방지 (30분)")
            .itemType("consumable")
            .price(50)
            .rarity("common")
            .imageUrl("☕")
            .isAvailable(true)
            .build());
    }
}
