import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_data.dart';

/// The only internet address the app ever calls: one small file made by
/// our GitHub backend. The phone never calls the price, dam or weather
/// websites itself.
const dataUrl =
    'https://raw.githubusercontent.com/Madhubabun/Dad-s_Project/data/data.json';

enum SyncResult { updated, notChanged, failed }

/// Downloads data.json and keeps the last good copy on the phone, so the
/// dashboard opens instantly and works without a network.
class DataRepository {
  DataRepository(this._prefs);

  static const _jsonKey = 'dashboard_json';
  static const _etagKey = 'dashboard_etag';

  final SharedPreferences _prefs;

  /// The saved copy, or null before the first successful download.
  DashboardData? cached() {
    final text = _prefs.getString(_jsonKey);
    if (text == null) return null;
    try {
      return DashboardData.fromJson(jsonDecode(text) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Asks for data.json. Sends the ETag of the saved copy, so if nothing
  /// changed the server answers "304 not modified" with no body and almost
  /// no mobile data is used.
  Future<SyncResult> refresh() async {
    try {
      final etag = _prefs.getString(_etagKey);
      final response = await http
          .get(
            Uri.parse(dataUrl),
            headers: {if (etag != null) 'If-None-Match': etag},
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 304) return SyncResult.notChanged;
      if (response.statusCode != 200) return SyncResult.failed;

      final text = utf8.decode(response.bodyBytes);
      final json = jsonDecode(text) as Map<String, dynamic>; // throws if broken
      final newVersion = json['version'];
      final oldVersion = cached()?.version;
      await _prefs.setString(_jsonKey, text);
      final newEtag = response.headers['etag'];
      if (newEtag != null) await _prefs.setString(_etagKey, newEtag);
      return newVersion != null && newVersion == oldVersion
          ? SyncResult.notChanged
          : SyncResult.updated;
    } catch (_) {
      // No network, timeout or a broken file: keep the saved copy.
      return SyncResult.failed;
    }
  }
}
