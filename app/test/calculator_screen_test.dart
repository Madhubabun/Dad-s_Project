import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raithe_raju/app_state.dart';
import 'package:raithe_raju/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // A small phone screen with Dad's font size turned up, to catch Telugu
  // text that does not fit.
  Future<void> pumpApp(WidgetTester tester, {String locale = 'te'}) async {
    tester.view.physicalSize = const Size(720, 1440);
    tester.view.devicePixelRatio = 2;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    SharedPreferences.setMockInitialValues({'locale': locale});
    final state = await AppState.load();
    await tester.pumpWidget(
      AppStateScope(state: state, child: const RaitheRajuApp()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens in Telugu and adding an item shows its problems', (
    tester,
  ) async {
    await pumpApp(tester);
    // The app opens on the Today tab; switch to the credit calculator.
    await tester.tap(find.text('అప్పు లెక్క'));
    await tester.pumpAndSettle();
    expect(find.text('ఎరువుల అప్పు లెక్క'), findsOneWidget);

    await tester.tap(find.text('కొత్త కొనుగోలు చేర్చు'));
    await tester.pumpAndSettle();
    // A new item has no amount yet: show the message, not a total.
    expect(
      find.text('ఎరుపు గుర్తు ఉన్నవి సరిచేస్తే మొత్తం కనిపిస్తుంది'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('ధర 0 కంటే ఎక్కువ ఉండాలి'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('ధర 0 కంటే ఎక్కువ ఉండాలి'), findsOneWidget);
  });

  testWidgets('settings switches to English', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.settings).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });
}
