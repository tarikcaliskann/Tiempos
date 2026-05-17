package com.timebank.timebank.credit;

import java.util.Arrays;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Sunulan zaman kredisi paketleri — fiyat ve dakika sunucuda doğrulanır.
 */
public enum CreditPackageCatalog {
    STARTER("starter", 1, 60, 0, 100, 100, 0, null),
    POPULAR("popular", 2, 120, 15, 200, 150, 25, "En Popüler"),
    PREMIUM("premium", 5, 300, 60, 500, 350, 30, "En Avantajlı"),
    ULTIMATE("ultimate", 10, 600, 120, 1000, 600, 40, null);

    private static final Map<String, CreditPackageCatalog> BY_ID = Arrays.stream(values())
            .collect(Collectors.toMap(CreditPackageCatalog::getId, Function.identity()));

    private final String id;
    private final int displayHours;
    private final int creditMinutes;
    private final int bonusMinutes;
    private final int originalPriceTry;
    private final int discountedPriceTry;
    private final int discountPercent;
    private final String badge;

    CreditPackageCatalog(
            String id,
            int displayHours,
            int creditMinutes,
            int bonusMinutes,
            int originalPriceTry,
            int discountedPriceTry,
            int discountPercent,
            String badge
    ) {
        this.id = id;
        this.displayHours = displayHours;
        this.creditMinutes = creditMinutes;
        this.bonusMinutes = bonusMinutes;
        this.originalPriceTry = originalPriceTry;
        this.discountedPriceTry = discountedPriceTry;
        this.discountPercent = discountPercent;
        this.badge = badge;
    }

    public static Optional<CreditPackageCatalog> findById(String id) {
        if (id == null || id.isBlank()) {
            return Optional.empty();
        }
        return Optional.ofNullable(BY_ID.get(id.trim().toLowerCase()));
    }

    public String getId() {
        return id;
    }

    public int getDisplayHours() {
        return displayHours;
    }

    public int getTotalMinutes() {
        return creditMinutes + bonusMinutes;
    }

    public int getCreditMinutes() {
        return creditMinutes;
    }

    public int getBonusMinutes() {
        return bonusMinutes;
    }

    public int getOriginalPriceTry() {
        return originalPriceTry;
    }

    public int getDiscountedPriceTry() {
        return discountedPriceTry;
    }

    public int getDiscountPercent() {
        return discountPercent;
    }

    public String getBadge() {
        return badge;
    }
}
