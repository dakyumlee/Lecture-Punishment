package com.dungeon.heotaehoon.config;

import com.dungeon.heotaehoon.entity.Instructor;
import com.dungeon.heotaehoon.entity.ShopItem;
import com.dungeon.heotaehoon.repository.InstructorRepository;
import com.dungeon.heotaehoon.repository.ShopItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final ShopItemRepository shopItemRepository;
    private final InstructorRepository instructorRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        initializeInstructor();
        shopItemRepository.deleteAll();
        createShopItems();
    }

    private void initializeInstructor() {
        if (instructorRepository.findByUsername("hth422").isEmpty()) {
            Instructor instructor = Instructor.builder()
                    .name("허태훈")
                    .username("hth422")
                    .password(passwordEncoder.encode("password1234!"))
                    .level(1)
                    .exp(0)
                    .rageGauge(50)
                    .build();
            
            instructorRepository.save(instructor);
            System.out.println("✅ 허태훈 강사 계정 초기화 완료!");
            System.out.println("   아이디: hth422");
            System.out.println("   비밀번호: password1234!");
        }
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
