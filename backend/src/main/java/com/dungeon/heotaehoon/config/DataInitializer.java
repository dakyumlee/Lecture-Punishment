package com.dungeon.heotaehoon.config;

import com.dungeon.heotaehoon.entity.ShopItem;
import com.dungeon.heotaehoon.repository.ShopItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final ShopItemRepository shopItemRepository;

    @Override
    public void run(String... args) {
        if (shopItemRepository.count() == 0) {
            createShopItems();
        }
    }

    private void createShopItems() {
        shopItemRepository.save(ShopItem.builder()
            .name("기본 교복")
            .description("평범한 학생 교복")
            .itemType("outfit")
            .price(0)
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("명품 양복")
            .description("허태훈도 인정한 멋진 양복")
            .itemType("outfit")
            .price(500)
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("후드티")
            .description("편안한 캐주얼룩")
            .itemType("outfit")
            .price(300)
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("운동복")
            .description("체육시간 필수템")
            .itemType("outfit")
            .price(200)
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("😊 미소")
            .description("기본 표정")
            .itemType("expression")
            .price(0)
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("😭 눈물")
            .description("허태훈에게 맞았을 때")
            .itemType("expression")
            .price(100)
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("😡 분노")
            .description("역으로 분노하기")
            .itemType("expression")
            .price(300)
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("😎 자신감")
            .description("만점 맞았을 때")
            .itemType("expression")
            .price(400)
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("🤯 멘붕")
            .description("시험 망했을 때")
            .itemType("expression")
            .price(200)
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("방어막")
            .description("허태훈의 분노를 1회 막아줌")
            .itemType("consumable")
            .price(1000)
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("힌트권")
            .description("퀴즈 힌트 1개 제공")
            .itemType("consumable")
            .price(500)
            .isAvailable(true)
            .build());

        shopItemRepository.save(ShopItem.builder()
            .name("부활권")
            .description("틀린 문제를 다시 풀 수 있음")
            .itemType("consumable")
            .price(800)
            .isAvailable(true)
            .build());
    }
}
