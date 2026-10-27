import 'package:flutter/material.dart';

import '../app_state.dart';
import '../calculator/interest.dart';
import '../l10n/app_localizations.dart';

/// Language and how the shop counts days. Kept short on purpose.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = AppStateScope.of(context);

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
