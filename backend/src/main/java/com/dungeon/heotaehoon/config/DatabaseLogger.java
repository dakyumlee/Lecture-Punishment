package com.dungeon.heotaehoon.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DatabaseLogger implements CommandLineRunner {
    
    @Value("${spring.datasource.url}")
    private String datasourceUrl;
    
    @Override
    public void run(String... args) {
        System.out.println("=".repeat(80));
        System.out.println("🔍 실제 연결된 DATABASE URL: " + datasourceUrl);
        System.out.println("=".repeat(80));
    }
}
