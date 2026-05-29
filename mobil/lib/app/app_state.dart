import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/auth_api.dart';

const _kToken = 'tiempos_mobile_token';
const _kUserId = 'tiempos_mobile_user_id';
const _kEmail = 'tiempos_mobile_email';
const _kFullName = 'tiempos_mobile_full_name';
const _kThemeMode = 'tiempos_mobile_theme_mode';
const _kLocaleLanguage = 'tiempos_mobile_locale_language';

class AppState extends ChangeNotifier {
  String? _token;
  String? _userId;
  String? _email;
  String? _fullName;
  ThemeMode _themeMode = ThemeMode.dark;
  /// `en` / `tr` when kullanıcı dil seçti; `null` ise cihaz dili (`MaterialApp.locale`).
  String? _localeLanguageCode;

  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  String? get fullName => _fullName;
  ThemeMode get themeMode => _themeMode;
  Locale? get localeOverride {
    final c = _localeLanguageCode;
    if (c == null || c.isEmpty) return null;
    return Locale(c);
  }

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> restoreSession() async {
    final p = await SharedPreferences.getInstance();
    _token = p.getString(_kToken);
    _userId = p.getString(_kUserId);
    _email = p.getString(_kEmail);
    _fullName = p.getString(_kFullName);
    final tm = p.getString(_kThemeMode);
    _themeMode = tm == 'light' ? ThemeMode.light : ThemeMode.dark;
    _localeLanguageCode = p.getString(_kLocaleLanguage);
    if (_localeLanguageCode != null && _localeLanguageCode!.isEmpty) {
      _localeLanguageCode = null;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kThemeMode, mode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  /// Web `settings` dil seçimi: `en` veya `tr`.
  Future<void> setAppLanguageCode(String code) async {
    final normalized = code.toLowerCase().startsWith('tr') ? 'tr' : 'en';
    _localeLanguageCode = normalized;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLocaleLanguage, normalized);
    notifyListeners();
  }

  Future<void> applyLoginResponse(LoginResponse res) async {
    _token = res.token;
    _userId = res.userId;
    _email = res.email;
    _fullName = res.fullName;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, res.token);
    await p.setString(_kUserId, res.userId);
    await p.setString(_kEmail, res.email);
    await p.setString(_kFullName, res.fullName);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final res = await loginRequest(email: email, password: password);
    await applyLoginResponse(res);
  }

  Future<void> applyProfileDisplayName(String fullName) async {
    final n = fullName.trim();
    if (n.isEmpty) return;
    _fullName = n;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kFullName, n);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _email = null;
    _fullName = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    await p.remove(_kUserId);
    await p.remove(_kEmail);
    await p.remove(_kFullName);
    notifyListeners();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      /* plugin / not initialized */
    }
  }
}
