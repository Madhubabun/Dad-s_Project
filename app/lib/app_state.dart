import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calculator/interest.dart';

/// Everything the app remembers on the phone: the chosen language and the
/// fertilizer credit list. Saved after every change, so nothing is lost if
/// the app is closed or the phone restarts. Works fully offline.
class AppState extends ChangeNotifier {
  AppState._(this._prefs, this.locale, this.sheet);

  static const _localeKey = 'locale';
  static const _sheetKey = 'credit_sheet';

  final SharedPreferences _prefs;

  /// Telugu ('te') by default; can be switched to English in settings.
  Locale locale;
  final CreditSheet sheet;

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = Locale(prefs.getString(_localeKey) ?? 'te');
    var sheet = CreditSheet();
    final saved = prefs.getString(_sheetKey);
    if (saved != null) {
      try {
        sheet = CreditSheet.fromJson(jsonDecode(saved) as Map<String, dynamic>);
      } catch (_) {
        // A damaged save should never stop the app from opening.
      }
    }
    return AppState._(prefs, locale, sheet);
  }

  void setLocale(Locale value) {
    locale = value;
    _prefs.setString(_localeKey, value.languageCode);
    notifyListeners();
  }

  /// Call after changing anything in [sheet]: redraws the screen and saves.
  void sheetChanged() {
    _prefs.setString(_sheetKey, jsonEncode(sheet.toJson()));
    notifyListeners();
  }
}

/// Gives every screen below it access to [AppState].
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.notifier!;
}
