import 'dart:convert';

import 'package:flutter/services.dart';

/// Web `profilePicklists.ts` — `ComboboxOption` ile aynı anlam.
class ProfilePicklistOption {
  const ProfilePicklistOption({required this.value, required this.label});

  final String value;
  final String label;
}

class _LangRow {
  _LangRow({required this.value, required this.labelEn, required this.labelTr});

  final String value;
  final String labelEn;
  final String labelTr;

  String labelForLocale(bool turkish) => turkish ? labelTr : labelEn;

  factory _LangRow.fromJson(Map<String, dynamic> j) {
    final lab = j['label'];
    Map<String, dynamic> m;
    if (lab is Map) {
      m = Map<String, dynamic>.from(lab);
    } else {
      m = {};
    }
    return _LangRow(
      value: j['value'] as String? ?? '',
      labelEn: m['en'] as String? ?? '',
      labelTr: m['tr'] as String? ?? '',
    );
  }
}

/// Web `profilePicklists` + `mergeLegacyOption`.
class ProfilePicklists {
  ProfilePicklists._({required List<String> locations, required List<_LangRow> langRows})
      : _locations = locations,
        _langRows = langRows;

  final List<String> _locations;
  final List<_LangRow> _langRows;

  static Future<ProfilePicklists> load() async {
    final locRaw = await rootBundle.loadString('assets/data/profile_locations.json');
    final langRaw = await rootBundle.loadString('assets/data/profile_languages.json');
    final locList = (jsonDecode(locRaw) as List).map((e) => '$e').toList();
    final langList = (jsonDecode(langRaw) as List)
        .whereType<Map>()
        .map((e) => _LangRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return ProfilePicklists._(locations: locList, langRows: langList);
  }

  List<ProfilePicklistOption> locationOptions() {
    return _locations.map((s) => ProfilePicklistOption(value: s, label: s)).toList();
  }

  List<ProfilePicklistOption> languageOptions(bool turkish) {
    return _langRows
        .map((r) => ProfilePicklistOption(value: r.value, label: r.labelForLocale(turkish)))
        .toList();
  }
}

/// Web `mergeLegacyOption`.
List<ProfilePicklistOption> mergeLegacyOption(
  List<ProfilePicklistOption> options,
  String current,
) {
  final t = current.trim();
  if (t.isEmpty) return options;
  final hit = options.any((o) => o.value == t || o.label == t);
  if (hit) return options;
  return [ProfilePicklistOption(value: t, label: t), ...options];
}
