import 'package:flutter/material.dart';

import 'calculator/calculator_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'l10n/app_localizations.dart';

/// Two big tabs at the bottom: today's dashboard and the credit calculator.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      // IndexedStack keeps each tab's scroll position and typed text.
      body: IndexedStack(
        index: _tab,
        children: const [DashboardScreen(), CalculatorScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        height: 76,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today, size: 32),
            label: l.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calculate, size: 32),
            label: l.navCredit,
          ),
        ],
      ),
    );
  }
}
