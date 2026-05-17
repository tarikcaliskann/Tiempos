/** Zaman kredisi paketleri — görüntüleme; fiyat/dakika sunucuda doğrulanır */
export interface CreditPackage {
  id: string;
  hours: number;
  originalPrice: number;
  discountedPrice: number;
  discount: number;
  badge?: string;
  features: string[];
}

export const CREDIT_PACKAGES: CreditPackage[] = [
  {
    id: "starter",
    hours: 1,
    originalPrice: 100,
    discountedPrice: 100,
    discount: 0,
    features: [
      "1 saatlik zaman kredisi",
      "Tüm becerilere erişim",
      "Anında aktivasyon",
      "7/24 destek",
    ],
  },
  {
    id: "popular",
    hours: 2,
    originalPrice: 200,
    discountedPrice: 150,
    discount: 25,
    badge: "En Popüler",
    features: [
      "2 saatlik zaman kredisi",
      "Tüm becerilere erişim",
      "Anında aktivasyon",
      "7/24 öncelikli destek",
      "Bonus: +15 dakika hediye",
    ],
  },
  {
    id: "premium",
    hours: 5,
    originalPrice: 500,
    discountedPrice: 350,
    discount: 30,
    badge: "En Avantajlı",
    features: [
      "5 saatlik zaman kredisi",
      "Tüm becerilere erişim",
      "Anında aktivasyon",
      "7/24 öncelikli destek",
      "Bonus: +1 saat hediye",
      "Özel etkinliklere erişim",
    ],
  },
  {
    id: "ultimate",
    hours: 10,
    originalPrice: 1000,
    discountedPrice: 600,
    discount: 40,
    features: [
      "10 saatlik zaman kredisi",
      "Tüm becerilere erişim",
      "Anında aktivasyon",
      "7/24 VIP destek",
      "Bonus: +2 saat hediye",
      "Özel etkinliklere erişim",
      "1 aylık premium üyelik",
    ],
  },
];

export const SELECTED_PACKAGE_KEY = "tiempos_selected_package";

export function getPackageById(id: string): CreditPackage | undefined {
  return CREDIT_PACKAGES.find((p) => p.id === id);
}
