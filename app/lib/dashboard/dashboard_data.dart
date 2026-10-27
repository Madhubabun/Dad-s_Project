// The data shown on the dashboard, read from data.json.
//
// Every field is optional: if the backend leaves something out (for
// example the dam scraper broke), that card shows "no data" instead of the
// app crashing. See backend/README.md for the file format.

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;
double? _num(Object? v) => v is num ? v.toDouble() : null;
int _int(Object? v) => v is num ? v.round() : 0;
Map<String, dynamic> _map(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : {};
List<Map<String, dynamic>> _list(Object? v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : [];

/// Common to every section: when it was fetched and whether it is fresh.
class SectionInfo {
  SectionInfo(Map<String, dynamic> json)
    : lastUpdated = _date(json['last_updated']),
      stale = json['status'] == 'stale';

  final DateTime? lastUpdated;

  /// The backend could not get new data and kept the last good values.
  final bool stale;
}

class DashboardData {
  DashboardData._(this.version, this.weather, this.prices, this.dam);

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final w = _map(json['weather']);
    final p = _map(json['prices']);
    final d = _map(json['dam']);
    return DashboardData._(
      json['version'] as String?,
      w.isEmpty ? null : WeatherInfo(w),
      p.isEmpty ? null : PriceInfo(p),
      d.isEmpty ? null : DamInfo(d),
    );
  }

  final String? version;
  final WeatherInfo? weather;
  final PriceInfo? prices;
  final DamInfo? dam;
}

// ---------------------------------------------------------------- weather

class WeatherInfo extends SectionInfo {
  WeatherInfo(super.json)
    : nowChance = _int(_map(json['now'])['rain_chance']),
      todayChance = _int(_map(json['today'])['rain_chance']),
      todayMm = _num(_map(json['today'])['rain_mm']) ?? 0,
      windMaxKmh = _int(_map(json['today'])['wind_max_kmh']),
      summaryKind = (_map(json['summary'])['kind'] as String?) ?? 'none',
      fromHour = _map(json['summary'])['from_hour'] as int?,
      days = _list(json['days']).map(DayForecast.new).toList();

  final int nowChance;

  /// Highest chance of rain for the rest of today.
  final int todayChance;
  final double todayMm;
  final int windMaxKmh;

  /// "none", "small", "likely" or "heavy". The words come from the ARB files.
  final String summaryKind;

  /// Hour (0–23) when rain becomes likely, or null.
  final int? fromHour;
  final List<DayForecast> days;
}

class DayForecast {
  DayForecast(Map<String, dynamic> json)
    : date = _date(json['date']),
      chance = _int(json['rain_chance']),
      mm = _num(json['rain_mm']) ?? 0,
      code = _int(json['code']);

  final DateTime? date;
  final int chance;
  final double mm;

  /// WMO weather code from Open-Meteo.
  final int code;
}

// ----------------------------------------------------------------- prices

class PriceInfo extends SectionInfo {
  PriceInfo(super.json)
    : mspSeason = _map(json['msp'])['season'] as String?,
      mspCommon = _num(_map(json['msp'])['common']),
      mspGradeA = _num(_map(json['msp'])['grade_a']),
      markets = _list(json['markets']).map(MarketPrices.new).toList();

  final String? mspSeason;
  final double? mspCommon;
  final double? mspGradeA;

  /// In the backend's order: primary market first, then backups.
  final List<MarketPrices> markets;

  /// Every variety name in any market, for the settings list.
  List<String> get allVarieties => {
    for (final m in markets)
      for (final v in m.varieties) v.name,
  }.toList();

  /// The price to show for [variety]: from [market] if it has one, else
  /// from the first backup market that does. Null means "no data".
  ({MarketPrices market, VarietyPrice price})? find(
    String variety,
    String? market,
  ) {
    final ordered = [
      ...markets.where((m) => m.name == market),
      ...markets.where((m) => m.name != market),
    ];
    for (final m in ordered) {
      for (final v in m.varieties) {
        if (v.name == variety) return (market: m, price: v);
      }
    }
    return null;
  }
}

class MarketPrices {
  MarketPrices(Map<String, dynamic> json)
    : name = (json['name'] as String?) ?? '',
      varieties = _list(json['varieties']).map(VarietyPrice.new).toList();

  final String name;
  final List<VarietyPrice> varieties;
}

class VarietyPrice {
  VarietyPrice(Map<String, dynamic> json)
    : name = (json['name'] as String?) ?? '',
      date = _date(json['date']),
      min = _num(json['min']),
      max = _num(json['max']),
      modal = _num(json['modal']),
      prevDate = _date(json['prev_date']),
      prevModal = _num(json['prev_modal']);

  final String name;

  /// The day this price was reported (may be older than today).
  final DateTime? date;
  final double? min;
  final double? max;
  final double? modal;
  final DateTime? prevDate;
  final double? prevModal;

  /// Change since the previous reported day, or null if unknown.
  double? get change =>
      modal != null && prevModal != null ? modal! - prevModal! : null;
}

// -------------------------------------------------------------------- dam

class DamInfo extends SectionInfo {
  DamInfo(super.json)
    : manual = json['source'] == 'manual',
      dams = _list(json['dams']).map(DamLevel.new).toList();

  /// Typed in by hand in backend/config.json because scraping is broken.
  final bool manual;
  final List<DamLevel> dams;
}

class DamLevel {
  DamLevel(Map<String, dynamic> json)
    : id = (json['id'] as String?) ?? '',
      date = _date(json['date']),
      levelM = _num(json['level_m']),
      fullLevelM = _num(json['full_level_m']),
      storageTmc = _num(json['storage_tmc']),
      fullStorageTmc = _num(json['full_storage_tmc']),
      percent = _num(json['percent']),
      inflowCusecs = _num(json['inflow_cusecs']),
      outflowCusecs = _num(json['outflow_cusecs']);

  /// "narayanpur" or "almatti"; the name shown comes from the ARB files.
  final String id;
  final DateTime? date;
  final double? levelM;
  final double? fullLevelM;
  final double? storageTmc;
  final double? fullStorageTmc;
  final double? percent;
  final double? inflowCusecs;
  final double? outflowCusecs;
}
