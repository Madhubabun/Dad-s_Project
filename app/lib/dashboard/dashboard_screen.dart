import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';
import '../format.dart';
import '../l10n/app_localizations.dart';
import '../settings/settings_screen.dart';
import 'dashboard_data.dart';
import 'data_repository.dart';
import 'rain_drops.dart';
import 'water_tank.dart';

/// The daily dashboard: paddy price, dam level and rain, each with the time
/// it was last updated. Always shows the saved copy first; pulling down
/// asks for new data.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // One small check when the app opens, after the saved data is shown.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppStateScope.of(context).refresh();
    });
  }

  Future<void> _pullToRefresh() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await AppStateScope.of(context).refresh();
    final text = switch (result) {
      SyncResult.updated => l.refreshUpdated,
      SyncResult.notChanged => l.refreshNoChange,
      SyncResult.failed => l.refreshFailed,
    };
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text, style: const TextStyle(fontSize: 18))),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = AppStateScope.of(context).dashboard;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          IconButton(
            iconSize: 32,
            tooltip: l.settingsTitle,
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _pullToRefresh,
        child: ListView(
          // Always scrollable, so pull-to-refresh works even when short.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
          children: [
            if (data == null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l.noDataYet, textAlign: TextAlign.center),
              ),
            if (data != null) ...[
              PriceCard(prices: data.prices),
              const SizedBox(height: 12),
              DamCard(dam: data.dam),
              const SizedBox(height: 12),
              RainCard(weather: data.weather),
            ],
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ shared bits

/// Card with a title row and the "updated at" line at the bottom.
class _DataCard extends StatelessWidget {
  const _DataCard({
    required this.icon,
    required this.title,
    required this.section,
    required this.child,
    this.decoration,
  });

  final IconData icon;
  final String title;
  final SectionInfo? section;
  final Widget child;

  /// Lets the price card glow green when the price goes up.
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: decoration ?? const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, size: 30, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
              if (section != null) ...[
                const SizedBox(height: 12),
                _UpdatedLine(section: section!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "Updated 27 Oct, 6:25 PM", plus a clear warning when the data is old.
class _UpdatedLine extends StatelessWidget {
  const _UpdatedLine({required this.section});

  final SectionInfo section;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final when = section.lastUpdated;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (when != null)
          Text(
            l.updatedAt(
              DateFormat('d MMM, h:mm a', lang).format(when.toLocal()),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        if (section.stale)
          Row(
            children: [
              Icon(Icons.history, color: theme.colorScheme.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.staleData,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// A label on the left, value on the right; wraps for long Telugu labels.
class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

String _number(double value, {int decimals = 0}) =>
    NumberFormat.decimalPatternDigits(
      locale: 'en_IN',
      decimalDigits: decimals,
    ).format(value);

/// Variety names arrive in English from the market data; known ones are
/// shown in Telugu.
String varietyLabel(AppLocalizations l, String name) =>
    switch (name.toLowerCase()) {
      'sona masuri' || 'sona masoori' || 'sona mahsuri' => l.varietySonaMasuri,
      'rnr' => l.varietyRnr,
      'bpt' => l.varietyBpt,
      _ => name,
    };

// ------------------------------------------------------------------ price

class PriceCard extends StatelessWidget {
  const PriceCard({super.key, required this.prices});

  final PriceInfo? prices;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = AppStateScope.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final found = prices?.find(state.variety, state.market);
    final price = found?.price;
    final change = price?.change;
    final up = change != null && change > 0;
    final down = change != null && change < 0;

    // Green glow when the price went up: the good news should stand out.
    final decoration = up
        ? const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFC8E6C9), Color(0xFF81C784)],
            ),
          )
        : down
        ? const BoxDecoration(color: Color(0xFFFFEBEE))
        : null;

    return _DataCard(
      icon: Icons.grass,
      title: '${l.priceCardTitle} · ${varietyLabel(l, state.variety)}',
      section: prices,
      decoration: decoration,
      child: price?.modal == null
          ? Text(l.noPriceData, style: theme.textTheme.bodyLarge)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 8,
                  children: [
                    Text(
                      rupees(price!.modal!),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: up ? const Color(0xFF1B5E20) : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        l.perQuintal,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
                if (price.min != null && price.max != null)
                  Text(
                    l.priceMinMax(rupees(price.min!), rupees(price.max!)),
                    style: theme.textTheme.bodyLarge,
                  ),
                const SizedBox(height: 8),
                _ChangeChip(change: change, since: price.prevDate, lang: lang),
                const SizedBox(height: 8),
                Text(
                  '${l.marketName(found!.market.name)} · '
                  '${l.priceOfDate(price.date == null ? '-' : shortDate(price.date!, lang))}',
                  style: theme.textTheme.bodyMedium,
                ),
                _OtherVarieties(market: found.market, mine: price.name),
                if (prices?.mspCommon != null) ...[
                  const Divider(height: 24),
                  Text(
                    l.mspTitle(prices!.mspSeason ?? ''),
                    style: theme.textTheme.titleMedium,
                  ),
                  _Line(l.mspCommon, rupees(prices!.mspCommon!)),
                  if (prices!.mspGradeA != null)
                    _Line(l.mspGradeA, rupees(prices!.mspGradeA!)),
                ],
              ],
            ),
    );
  }
}

/// ▲ Up ₹50 / ▼ Down ₹30 / No change. Arrow and words, never colour alone.
class _ChangeChip extends StatelessWidget {
  const _ChangeChip({
    required this.change,
    required this.since,
    required this.lang,
  });

  final double? change;
  final DateTime? since;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (change == null) return const SizedBox.shrink();
    final (icon, color, text) = change! > 0
        ? (
            Icons.arrow_upward,
            const Color(0xFF1B5E20),
            l.priceUp(rupees(change!)),
          )
        : change! < 0
        ? (
            Icons.arrow_downward,
            const Color(0xFFC62828),
            l.priceDown(rupees(-change!)),
          )
        : (Icons.remove, theme.colorScheme.onSurfaceVariant, l.priceSame);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Icon(icon, color: color, size: 30),
        Text(text, style: theme.textTheme.titleLarge?.copyWith(color: color)),
        if (since != null)
          Text(
            l.priceComparedTo(shortDate(since!, lang)),
            style: theme.textTheme.bodyMedium,
          ),
      ],
    );
  }
}

class _OtherVarieties extends StatelessWidget {
  const _OtherVarieties({required this.market, required this.mine});

  final MarketPrices market;
  final String mine;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final others = market.varieties
        .where((v) => v.name != mine && v.modal != null)
        .toList();
    if (others.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 24),
        Text(l.otherVarieties, style: theme.textTheme.titleMedium),
        for (final v in others)
          _Line(varietyLabel(l, v.name), rupees(v.modal!)),
      ],
    );
  }
}

// -------------------------------------------------------------------- dam

class DamCard extends StatelessWidget {
  const DamCard({super.key, required this.dam});

  final DamInfo? dam;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dams = dam?.dams ?? const [];
    return _DataCard(
      icon: Icons.water,
      title: l.damCardTitle,
      section: dam,
      child: dams.isEmpty
          ? Text(l.noDamData, style: theme.textTheme.bodyLarge)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (dam!.manual)
                  Text(l.damManual, style: theme.textTheme.bodyMedium),
                for (final (i, d) in dams.indexed) ...[
                  if (i > 0) const Divider(height: 28),
                  _DamRow(dam: d),
                ],
              ],
            ),
    );
  }
}

class _DamRow extends StatelessWidget {
  const _DamRow({required this.dam});

  final DamLevel dam;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final name = dam.id == 'almatti' ? l.damAlmatti : l.damNarayanpur;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dam.percent != null) ...[
              WaterTank(percent: dam.percent!),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (dam.percent != null)
                    Text(
                      '${dam.percent!.round()}% ${l.damFull}',
                      style: theme.textTheme.titleLarge,
                    ),
                  if (dam.levelM != null)
                    _Line(
                      l.damLevel,
                      l.metres(_number(dam.levelM!, decimals: 2)),
                    ),
                  if (dam.fullLevelM != null)
                    _Line(
                      l.damFullLevel,
                      l.metres(_number(dam.fullLevelM!, decimals: 2)),
                    ),
                  if (dam.storageTmc != null)
                    _Line(
                      l.damStorage,
                      dam.fullStorageTmc != null
                          ? '${_number(dam.storageTmc!, decimals: 2)} / ${l.tmc(_number(dam.fullStorageTmc!, decimals: 2))}'
                          : l.tmc(_number(dam.storageTmc!, decimals: 2)),
                    ),
                  if (dam.inflowCusecs != null)
                    _Line(l.damInflow, l.cusecs(_number(dam.inflowCusecs!))),
                  if (dam.outflowCusecs != null)
                    _Line(l.damOutflow, l.cusecs(_number(dam.outflowCusecs!))),
                ],
              ),
            ),
          ],
        ),
        if (dam.date != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l.dataDate(shortDate(dam.date!, lang)),
              style: theme.textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------------- rain

class RainCard extends StatelessWidget {
  const RainCard({super.key, required this.weather});

  final WeatherInfo? weather;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final w = weather;
    if (w == null) {
      return _DataCard(
        icon: Icons.umbrella,
        title: l.rainCardTitle,
        section: null,
        child: Text(l.noDataYet, style: theme.textTheme.bodyLarge),
      );
    }
    final likely = w.summaryKind == 'likely' || w.summaryKind == 'heavy';
    return FallingRain(
      active: likely,
      child: _DataCard(
        icon: Icons.umbrella,
        title: l.rainCardTitle,
        section: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(rainSummary(l, w), style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _RainNumber(label: l.rainNow, chance: w.nowChance),
                _RainNumber(
                  label: l.rainRestOfToday,
                  chance: w.todayChance,
                  mm: w.todayMm,
                ),
              ],
            ),
            if (w.days.isNotEmpty) ...[
              const Divider(height: 28),
              Text(l.nextDays, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final d in w.days) Expanded(child: _DayColumn(day: d)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The one-line summary, built here so all wording stays translatable.
String rainSummary(AppLocalizations l, WeatherInfo w) {
  final time = w.fromHour == null ? null : hourLabel(l, w.fromHour!);
  return switch (w.summaryKind) {
    'heavy' => time == null ? l.rainHeavyToday : l.rainHeavy(time),
    'likely' => time == null ? l.rainLikelyToday : l.rainLikely(time),
    'small' => l.rainSmall,
    _ => l.rainNone,
  };
}

/// 16 → "సాయంత్రం 4" / "4 PM".
String hourLabel(AppLocalizations l, int hour) {
  final h12 = hour % 12 == 0 ? 12 : hour % 12;
  if (hour < 5) return l.hourNightAm(h12);
  if (hour < 12) return l.hourMorning(h12);
  if (hour < 16) return l.hourNoon(h12);
  if (hour < 19) return l.hourEvening(h12);
  return l.hourNightPm(h12);
}

class _RainNumber extends StatelessWidget {
  const _RainNumber({required this.label, required this.chance, this.mm});

  final String label;
  final int chance;
  final double? mm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Text(
          '$chance%',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        RainDrops(chance: chance),
        if (mm != null)
          Text(
            l.millimetres(_number(mm!, decimals: 1)),
            style: theme.textTheme.bodyLarge,
          ),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({required this.day});

  final DayForecast day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      children: [
        Text(
          day.date == null ? '' : DateFormat('EEE', lang).format(day.date!),
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        Icon(weatherIcon(day.code), size: 36, color: const Color(0xFF1E88E5)),
        Text(
          '${day.chance}%',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Simple picture for a WMO weather code (Open-Meteo).
IconData weatherIcon(int code) {
  if (code >= 95) return Icons.thunderstorm;
  if (code >= 51) return Icons.water_drop;
  if (code >= 45) return Icons.foggy;
  if (code >= 2) return Icons.cloud;
  return Icons.wb_sunny;
}
