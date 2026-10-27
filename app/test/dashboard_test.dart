import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raithe_raju/app_state.dart';
import 'package:raithe_raju/dashboard/dashboard_data.dart';
import 'package:raithe_raju/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A data.json like the backend makes (values from 27-Oct-2026).
final sample = {
  'schema': 1,
  'version': 'abc',
  'weather': {
    'status': 'ok',
    'last_updated': '2026-10-27T18:25:29+05:30',
    'now': {'rain_chance': 10},
    'today': {'rain_chance': 80, 'rain_mm': 18.5, 'wind_max_kmh': 14},
    'summary': {'kind': 'heavy', 'from_hour': 16},
    'days': [
      {'date': '2026-10-28', 'rain_chance': 22, 'rain_mm': 1.6, 'code': 55},
      {'date': '2026-10-29', 'rain_chance': 35, 'rain_mm': 11.5, 'code': 81},
    ],
  },
  'dam': {
    'status': 'ok',
    'last_updated': '2026-10-27T10:31:00+05:30',
    'source': 'ksndmc',
    'dams': [
      {
        'id': 'narayanpur',
        'date': '2026-10-27',
        'level_m': 488.74,
        'full_level_m': 492.25,
        'storage_tmc': 19.73,
        'full_storage_tmc': 33.31,
        'percent': 59,
        'inflow_cusecs': 107,
        'outflow_cusecs': 1629,
      },
    ],
  },
  'prices': {
    'status': 'stale',
    'last_updated': '2026-10-27T19:05:00+05:30',
    'msp': {'season': '2025-26', 'common': 2369, 'grade_a': 2389},
    'markets': [
      {
        'name': 'Raichur',
        'varieties': [
          {
            'name': 'Sona Masuri',
            'date': '2026-10-27',
            'min': 2300,
            'max': 2650,
            'modal': 2500,
            'prev_date': '2026-10-26',
            'prev_modal': 2450,
          },
          {'name': 'RNR', 'date': '2026-10-27', 'modal': 2400},
        ],
      },
      {
        'name': 'Sindhanur',
        'varieties': [
          {'name': 'BPT', 'date': '2026-10-25', 'modal': 2200},
        ],
      },
    ],
  },
};

void main() {
  test('reads data.json and finds a variety in a backup market', () {
    final d = DashboardData.fromJson(sample);
    expect(d.weather!.summaryKind, 'heavy');
    expect(d.dam!.dams.single.percent, 59);
    expect(d.prices!.stale, isTrue);
    expect(d.prices!.find('Sona Masuri', null)!.price.change, 50);
    // BPT is not in Raichur, so the backup market is used.
    expect(d.prices!.find('BPT', 'Raichur')!.market.name, 'Sindhanur');
    expect(d.prices!.find('Unknown', null), isNull);
  });

  test('missing or broken sections never crash', () {
    final d = DashboardData.fromJson({
      'weather': 'oops',
      'dam': {'dams': 'x'},
    });
    expect(d.weather, isNull);
    expect(d.dam!.dams, isEmpty);
    expect(d.prices, isNull);
  });

  testWidgets('dashboard shows the saved data in Telugu', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'locale': 'te',
      'dashboard_json': jsonEncode(sample),
    });
    final state = await AppState.load();
    await tester.pumpWidget(
      AppStateScope(state: state, child: const RaitheRajuApp()),
    );
    // Animations (water, rain) run forever, so pump a fixed time instead
    // of waiting for them to settle.
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('₹2,500'), findsOneWidget);
    expect(find.text('₹50 పెరిగింది'), findsOneWidget);
    expect(find.text('పాత సమాచారం – కొత్తది ఇంకా రాలేదు'), findsOneWidget);
    final page = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('59%'), 300, scrollable: page);
    expect(find.text('59%'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('సాయంత్రం 4 తర్వాత భారీ వర్షం పడే అవకాశం ఉంది'),
      300,
      scrollable: page,
    );
  });
}
