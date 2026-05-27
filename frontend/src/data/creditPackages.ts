/** Zaman kredisi paketleri — görüntüleme; fiyat/dakika sunucuda doğrulanır. Metinler locale dosyalarında. */
export interface CreditPackage {
  id: string;
  hours: number;
  originalPrice: number;
  discountedPrice: number;
  discount: number;
  badge?: string;
}

export const CREDIT_PACKAGES: CreditPackage[] = [
  {
    id: "starter",
    hours: 1,
    originalPrice: 100,
    discountedPrice: 100,
    discount: 0,
  },
  {
    id: "popular",
    hours: 2,
    originalPrice: 200,
    discountedPrice: 150,
    discount: 25,
    badge: "En Popüler",
  },
  {
    id: "premium",
    hours: 5,
    originalPrice: 500,
    discountedPrice: 350,
    discount: 30,
    badge: "En Avantajlı",
  },
  {
    id: "ultimate",
    hours: 10,
    originalPrice: 1000,
    discountedPrice: 600,
    discount: 40,
  },
];

export const SELECTED_PACKAGE_KEY = "tiempos_selected_package";

export function getPackageById(id: string): CreditPackage | undefined {
  return CREDIT_PACKAGES.find((p) => p.id === id);
}
