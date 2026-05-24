import 'api_client.dart';

class CreditCheckoutDto {
  CreditCheckoutDto({
    required this.sessionId,
    required this.packageId,
    required this.displayHours,
    required this.amountTry,
    required this.totalMinutes,
    required this.provider,
    required this.demoMode,
    this.checkoutUrl,
  });

  final String sessionId;
  final String packageId;
  final int displayHours;
  final int amountTry;
  final int totalMinutes;
  final String provider;
  final bool demoMode;
  final String? checkoutUrl;

  factory CreditCheckoutDto.fromJson(Map<String, dynamic> j) {
    return CreditCheckoutDto(
      sessionId: '${j['sessionId'] ?? ''}',
      packageId: '${j['packageId'] ?? ''}',
      displayHours: (j['displayHours'] as num?)?.toInt() ?? 0,
      amountTry: (j['amountTry'] as num?)?.toInt() ?? 0,
      totalMinutes: (j['totalMinutes'] as num?)?.toInt() ?? 0,
      provider: j['provider'] as String? ?? '',
      demoMode: j['demoMode'] == true,
      checkoutUrl: j['checkoutUrl'] as String?,
    );
  }
}

class CreditPurchaseCompleteDto {
  CreditPurchaseCompleteDto({
    required this.timeCreditMinutes,
    required this.minutesAdded,
    required this.displayHours,
    required this.amountTry,
  });

  final int timeCreditMinutes;
  final int minutesAdded;
  final int displayHours;
  final int amountTry;

  factory CreditPurchaseCompleteDto.fromJson(Map<String, dynamic> j) {
    return CreditPurchaseCompleteDto(
      timeCreditMinutes: (j['timeCreditMinutes'] as num?)?.toInt() ?? 0,
      minutesAdded: (j['minutesAdded'] as num?)?.toInt() ?? 0,
      displayHours: (j['displayHours'] as num?)?.toInt() ?? 0,
      amountTry: (j['amountTry'] as num?)?.toInt() ?? 0,
    );
  }
}

Future<CreditCheckoutDto> startCreditCheckout({
  required String token,
  required String packageId,
}) async {
  final data = await apiFetch(
    '/api/credits/checkout',
    method: 'POST',
    body: {'packageId': packageId},
    token: token,
  );
  if (data is! Map) throw StateError('Invalid checkout response');
  return CreditCheckoutDto.fromJson(Map<String, dynamic>.from(data));
}

Future<CreditPurchaseCompleteDto> completeCreditPurchase({
  required String token,
  required String sessionId,
}) async {
  final data = await apiFetch(
    '/api/credits/complete/${Uri.encodeComponent(sessionId)}',
    method: 'POST',
    token: token,
  );
  if (data is! Map) throw StateError('Invalid complete response');
  return CreditPurchaseCompleteDto.fromJson(Map<String, dynamic>.from(data));
}
