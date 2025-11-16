package com.dungeon.heotaehoon.service;

import org.springframework.stereotype.Service;
import java.util.Random;

@Service
public class RageMessageService {
    
    private static final String[] RAGE_MESSAGES = {
        "너는 복습을 했니? 했으면 이럴 리가 없지 ㅋㅋ",
        "목졸라뿐다",
        "니대가리로 이해가 가긴하겠니",
        "야 그건 기본이잖아",
        "아니야 네가 못한 게 아니라 세상이 널 버린 거야",
        "이 정도로 날 막을 수 있을 것 같나!",
        "공부는 말이지… 이 세상에서 제일 귀찮은 사랑이야…",
        "너도 힘들었겠지… 그래도 복습은 해야지",
        "진짜 안 외웠구나... 뒤진다",
        "이게 틀리면 과제 3배다"
    };
    
    private static final String[] PRAISE_MESSAGES = {
        "오 드디어 하나 맞췄네!",
        "이정도면 괜찮은데?",
        "계속 이렇게만 해봐",
        "허태훈의 감탄 효과 발동!",
        "좋아, 이 기세를 몰아가자!",
        "제법인데? 다음 문제도 도전해봐",
        "훌륭해! 이 정도면 합격이야",
        "완벽한 답이야!",
        "역시 내 제자답군",
        "이 속도로 계속 가자!"
    };
    
    private final Random random = new Random();
    
    public String getRageMessage() {
        return RAGE_MESSAGES[random.nextInt(RAGE_MESSAGES.length)];
    }
    
    public String getPraiseMessage() {
        return PRAISE_MESSAGES[random.nextInt(PRAISE_MESSAGES.length)];
    }
}
