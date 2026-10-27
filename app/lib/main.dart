import 'package:flutter/material.dart';

import 'app_state.dart';
import 'home_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await AppState.load();
  runApp(AppStateScope(state: state, child: const RaitheRajuApp()));
}

class RaitheRajuApp extends StatelessWidget {
  const RaitheRajuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: state.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      // Includes Flutter's own Telugu texts, e.g. for the date picker.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}

/// Large, simple, green theme. Body text is at least 18sp so it is easy to
/// read; Telugu letters need the extra size even more than English.
ThemeData buildTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
    useMaterial3: true,
  );
  final t = base.textTheme;
  return base.copyWith(
    textTheme: t.copyWith(
      headlineMedium: t.headlineMedium?.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: t.titleLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: t.titleMedium?.copyWith(fontSize: 20),
      bodyLarge: t.bodyLarge?.copyWith(fontSize: 20),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 18),
      labelLarge: t.labelLarge?.copyWith(fontSize: 18),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 18)),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      labelStyle: TextStyle(fontSize: 18),
      floatingLabelStyle: TextStyle(fontSize: 18),
    ),
  );
}
