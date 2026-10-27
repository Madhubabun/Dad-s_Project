import 'package:flutter/material.dart';

import '../app_state.dart';
import '../calculator/interest.dart';
import '../dashboard/dashboard_screen.dart' show varietyLabel;
import '../l10n/app_localizations.dart';

/// Language and how the shop counts days. Kept short on purpose.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = AppStateScope.of(context);
    final prices = state.dashboard?.prices;
    // Varieties the market reports, plus the three Dad grows, in one list.
    final varieties = {
      AppState.defaultVariety,
      'RNR',
      'BPT',
      ...?prices?.allVarieties,
      state.variety,
    }.toList();
    final markets =
        prices?.markets.map((m) => m.name).toList() ?? const <String>[];

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(l.language, style: theme.textTheme.titleLarge),
          RadioGroup<String>(
            groupValue: state.locale.languageCode,
            onChanged: (code) {
              if (code != null) state.setLocale(Locale(code));
            },
            // Each language is written in its own script, so Dad can find
            // Telugu even if the app is showing English.
            child: const Column(
              children: [
                RadioListTile<String>(value: 'te', title: Text('తెలుగు')),
                RadioListTile<String>(value: 'en', title: Text('English')),
              ],
            ),
          ),
          const Divider(height: 32),
          Text(l.myVariety, style: theme.textTheme.titleLarge),
          RadioGroup<String>(
            groupValue: state.variety,
            onChanged: (v) {
              if (v != null) state.setVariety(v);
            },
            child: Column(
              children: [
                for (final v in varieties)
                  RadioListTile<String>(
                    value: v,
                    title: Text(varietyLabel(l, v)),
                  ),
              ],
            ),
          ),
          // Markets come from the downloaded data, so this appears once
          // the first prices have arrived.
          if (markets.length > 1) ...[
            const Divider(height: 32),
            Text(l.myMarket, style: theme.textTheme.titleLarge),
            RadioGroup<String>(
              groupValue: state.market ?? markets.first,
              onChanged: (m) {
                if (m != null) state.setMarket(m);
              },
              child: Column(
                children: [
                  for (final m in markets)
                    RadioListTile<String>(value: m, title: Text(m)),
                ],
              ),
            ),
          ],
          const Divider(height: 32),
          Text(l.dayCountMethod, style: theme.textTheme.titleLarge),
          RadioGroup<DayCount>(
            groupValue: state.sheet.dayCount,
            onChanged: (value) {
              if (value == null) return;
              state.sheet.dayCount = value;
              state.sheetChanged();
            },
            child: Column(
              children: [
                RadioListTile<DayCount>(
                  value: DayCount.exactDays,
                  title: Text(l.dayCountExact),
                ),
                RadioListTile<DayCount>(
                  value: DayCount.partMonthIsFull,
                  title: Text(l.dayCountPartMonth),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
