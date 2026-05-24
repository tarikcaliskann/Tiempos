/// Web `frontend/src/data/creditPackages.ts` ile aynı id’ler.
class CreditPackage {
  const CreditPackage({
    required this.id,
    required this.hours,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discount,
    this.badge,
    required this.features,
  });

  final String id;
  final int hours;
  final int originalPrice;
  final int discountedPrice;
  final int discount;
  final String? badge;
  final List<String> features;
}

const List<CreditPackage> creditPackages = [
  CreditPackage(
    id: 'starter',
    hours: 1,
    originalPrice: 100,
    discountedPrice: 100,
    discount: 0,
    features: [
      '1 hour time credit',
      'Access to all skills',
      'Instant activation',
      '24/7 support',
    ],
  ),
  CreditPackage(
    id: 'popular',
    hours: 2,
    originalPrice: 200,
    discountedPrice: 150,
    discount: 25,
    badge: 'Most popular',
    features: [
      '2 hours time credit',
      'Access to all skills',
      'Instant activation',
      'Priority support',
      'Bonus: +15 minutes',
    ],
  ),
  CreditPackage(
    id: 'premium',
    hours: 5,
    originalPrice: 500,
    discountedPrice: 350,
    discount: 30,
    badge: 'Best value',
    features: [
      '5 hours time credit',
      'Access to all skills',
      'Instant activation',
      'Priority support',
      'Bonus: +1 hour',
      'Special events access',
    ],
  ),
  CreditPackage(
    id: 'ultimate',
    hours: 10,
    originalPrice: 1000,
    discountedPrice: 600,
    discount: 40,
    features: [
      '10 hours time credit',
      'Access to all skills',
      'Instant activation',
      'VIP support',
      'Bonus: +2 hours',
      'Special events access',
      '1 month premium',
    ],
  ),
];

CreditPackage? getPackageById(String id) {
  for (final p in creditPackages) {
    if (p.id == id) return p;
  }
  return null;
}
