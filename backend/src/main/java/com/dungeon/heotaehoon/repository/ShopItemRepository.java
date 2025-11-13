package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.ShopItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ShopItemRepository extends JpaRepository<ShopItem, String> {
    List<ShopItem> findByIsAvailableTrue();
    List<ShopItem> findByItemType(String itemType);
}
