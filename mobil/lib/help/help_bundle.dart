import 'package:flutter/material.dart';

import '../app/app_state.dart';
import 'help_bundle_en.dart';
import 'help_bundle_tr.dart';
import 'help_models.dart';

HelpCenterBundle helpBundleFor(BuildContext context, AppState appState) {
  final o = appState.localeOverride?.languageCode;
  if (o != null) {
    return o.toLowerCase().startsWith('tr') ? kHelpBundleTr : kHelpBundleEn;
  }
  final d = Localizations.localeOf(context).languageCode.toLowerCase();
  return d.startsWith('tr') ? kHelpBundleTr : kHelpBundleEn;
}
