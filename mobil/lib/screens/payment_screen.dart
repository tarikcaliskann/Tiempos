import 'package:flutter/material.dart';

import '../app/app_state.dart';
import '../language/profile_l10n.dart';
import '../language/shell_l10n.dart';
import '../widgets/app_chrome.dart';

// -----------------------------------------------------------------------------
// Ödeme kısmı şimdilik olmayacak — aşağıda önceki akışın özeti (tam kod: git geçmişi).
//
// Eski davranış:
// - `dart:math` Random, `url_launcher`, `credits_api` (`startCreditCheckout`, `completeCreditPurchase`).
// - `checkoutUrl` dolu ve `demoMode` false ise harici tarayıcıda ödeme + "I've paid" ile tamamlama.
// - Aksi durumda 3 sn gecikme ve %10 olasılıkla sahte hata veya doğrudan `completeCreditPurchase` (demo).
// - Kart alanları yalnızca istemci doğrulaması; gerçek tahsilat checkout URL üzerinden yönlendiriliyordu.
// Tekrar açılırken bu dosyanın geçmiş sürümünü geri yükleyin veya `buy_credits_screen` ile birlikte bağlayın.
// -----------------------------------------------------------------------------

/// Geçici bilgilendirme ekranı; uygulama içinden ödeme akışı şu an kapalı.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({
    super.key,
    required this.appState,
    required this.packageId,
  });

  /// Korunur; ödeme tekrar açıldığında kullanılacak.
  // ignore: unused_field
  final AppState appState;
  /// Korunur; ödeme tekrar açıldığında kullanılacak.
  // ignore: unused_field
  final String packageId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shell = ShellL10n.of(context);
    final profile = ProfileL10n.of(context);
    return Scaffold(
      appBar: AppChrome.gradientAppBar(title: shell.buyTimeCredits),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            profile.paymentDisabledMobile,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
