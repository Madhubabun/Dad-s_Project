import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calculator/interest.dart';
import 'dashboard/dashboard_data.dart';
import 'dashboard/data_repository.dart';

/// Everything the app remembers on the phone: the chosen language, Dad's
/// variety and market, the fertilizer credit list and the last downloaded
/// dashboard data. Saved after every change, so nothing is lost if the app
/// is closed or the phone restarts. Works fully offline.
class AppState extends ChangeNotifier {
  AppState._(this._prefs, this.locale, this.sheet)
    : repository = DataRepository(_prefs),
      variety = _prefs.getString(_varietyKey) ?? defaultVariety,
      market = _prefs.getString(_marketKey) {
    dashboard = repository.cached();
  }

  static const _localeKey = 'locale';
  static const _sheetKey = 'credit_sheet';
  static const _varietyKey = 'my_variety';
  static const _marketKey = 'my_market';
  static const defaultVariety = 'Sona Masuri';

  final SharedPreferences _prefs;
  final DataRepository repository;

  /// Telugu ('te') by default; can be switched to English in settings.
  Locale locale;
  final CreditSheet sheet;

  /// Last downloaded dashboard data, or null before the first download.
  DashboardData? dashboard;

  /// "My variety" and "My market" from settings. A null market means the
  /// backend's first (primary) market.
  String variety;
  String? market;

  /// Latest modal price for Dad's variety, used by the credit calculator.
  double? get myPaddyPrice =>
      dashboard?.prices?.find(variety, market)?.price.modal;

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

  void setVariety(String value) {
    variety = value;
    _prefs.setString(_varietyKey, value);
    notifyListeners();
  }

  void setMarket(String value) {
    market = value;
    _prefs.setString(_marketKey, value);
    notifyListeners();
  }

  /// Downloads data.json if it changed. Only ever one small request.
  Future<SyncResult> refresh() async {
    final result = await repository.refresh();
    if (result == SyncResult.updated) {
      dashboard = repository.cached();
      notifyListeners();
    }
    return result;
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
