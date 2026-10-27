import 'package:flutter_test/flutter_test.dart';
import 'package:raithe_raju/calculator/interest.dart';

void main() {
  final payback = DateTime(2026, 10, 27);

  CreditSheet exampleSheet() => CreditSheet(
    rate: 2,
    rateType: RateType.perHundredPerMonth,
    dayCount: DayCount.exactDays,
    commonPaybackOn: payback,
    purchases: [
      Purchase(
        id: 'u',
        name: 'Urea',
        amount: 1200,
        boughtOn: DateTime(2026, 7, 5),
      ),
      Purchase(
        id: 'd',
        name: 'DAP',
        amount: 2800,
        boughtOn: DateTime(2026, 7, 20),
      ),
      Purchase(
        id: 'p',
        name: 'Potash',
        amount: 1600,
        boughtOn: DateTime(2026, 8, 15),
      ),
    ],
  );

  group('₹2 per ₹100 per month, exact days / 30, paying back 27-Oct-2026', () {
    test('Urea ₹1,200 from 05-Jul → 114 days, ≈ ₹91', () {
      final sheet = exampleSheet();
      final r = sheet.resultFor(sheet.purchases[0]);
      expect(r.days, 114);
      expect(r.interest.round(), 91);
      expect(r.total.round(), 1291);
    });

    test('DAP ₹2,800 from 20-Jul → 99 days, ≈ ₹185', () {
      final sheet = exampleSheet();
      final r = sheet.resultFor(sheet.purchases[1]);
      expect(r.days, 99);
      expect(r.interest.round(), 185);
    });

    test('Potash ₹1,600 from 15-Aug → 73 days, ≈ ₹78', () {
      final sheet = exampleSheet();
      final r = sheet.resultFor(sheet.purchases[2]);
      expect(r.days, 73);
      expect(r.interest.round(), 78);
    });

    test('totals: borrowed ₹5,600, interest ≈ ₹354, to pay ≈ ₹5,954', () {
      final s = exampleSheet().summary();
      expect(s.hasErrors, isFalse);
      expect(s.totalBorrowed, 5600);
      expect(s.totalInterest.round(), 354);
      expect(s.amountToPay.round(), 5954);
    });
  });

  test('yearly mode: ₹1,000 at 7% per year for 365 days → ₹70', () {
    final sheet = CreditSheet(
      rate: 7,
      rateType: RateType.percentPerYear,
      commonPaybackOn: DateTime(2026, 1, 1),
      purchases: [
        Purchase(id: 'a', amount: 1000, boughtOn: DateTime(2025, 1, 1)),
      ],
    );
    final r = sheet.resultFor(sheet.purchases.first);
    expect(r.days, 365);
    expect(r.interest, closeTo(70, 0.001));
  });

  group('validation', () {
    test('bought after the payback date is an error, not a wrong total', () {
      final sheet = exampleSheet();
      sheet.purchases.add(
        Purchase(id: 'x', amount: 500, boughtOn: DateTime(2026, 11, 1)),
      );
      final r = sheet.resultFor(sheet.purchases.last);
      expect(r.error, PurchaseError.boughtAfterPayback);
      expect(sheet.summary().hasErrors, isTrue);
    });

    test('zero amount is an error', () {
      final sheet = exampleSheet();
      sheet.purchases.add(
        Purchase(id: 'z', amount: 0, boughtOn: DateTime(2026, 8, 1)),
      );
      expect(
        sheet.resultFor(sheet.purchases.last).error,
        PurchaseError.amountNotPositive,
      );
      expect(sheet.summary().hasErrors, isTrue);
    });

    test('missing dates are errors', () {
      final sheet = CreditSheet(purchases: [Purchase(id: 'a', amount: 100)]);
      expect(
        sheet.resultFor(sheet.purchases.first).error,
        PurchaseError.missingBoughtDate,
      );
      sheet.purchases.first.boughtOn = DateTime(2026, 8, 1);
      expect(
        sheet.resultFor(sheet.purchases.first).error,
        PurchaseError.missingPaybackDate,
      );
    });

    test('same day bought and paid back is 0 days, 0 interest', () {
      final sheet = CreditSheet(
        commonPaybackOn: DateTime(2026, 8, 1),
        purchases: [
          Purchase(id: 'a', amount: 100, boughtOn: DateTime(2026, 8, 1)),
        ],
      );
      final r = sheet.resultFor(sheet.purchases.first);
      expect(r.isValid, isTrue);
      expect(r.days, 0);
      expect(r.interest, 0);
    });
  });

  group('"same payback date for all items" switch', () {
    test('OFF pre-fills each item with the common date; items can differ', () {
      final sheet = exampleSheet();
      sheet.setSamePaybackForAll(false);
      for (final p in sheet.purchases) {
        expect(p.paybackOn, payback);
      }
      // Change only Urea's date: 05-Jul → 04-Aug is 30 days → ₹24.
      sheet.purchases[0].paybackOn = DateTime(2026, 8, 4);
      final r = sheet.resultFor(sheet.purchases[0]);
      expect(r.days, 30);
      expect(r.interest, closeTo(24, 0.001));
      // Others still use 27-Oct.
      expect(sheet.resultFor(sheet.purchases[1]).days, 99);
    });

    test('back ON resets every item to the common date', () {
      final sheet = exampleSheet();
      sheet.setSamePaybackForAll(false);
      sheet.purchases[0].paybackOn = DateTime(2026, 8, 4);
      sheet.setSamePaybackForAll(true);
      expect(sheet.purchases[0].paybackOn, payback);
      expect(sheet.resultFor(sheet.purchases[0]).days, 114);
      expect(sheet.summary().totalInterest.round(), 354);
    });
  });

  group('"any part of a month is a full month"', () {
    test('month counting', () {
      expect(monthsRoundedUp(DateTime(2026, 7, 5), DateTime(2026, 8, 5)), 1);
      expect(monthsRoundedUp(DateTime(2026, 7, 5), DateTime(2026, 8, 6)), 2);
      expect(monthsRoundedUp(DateTime(2026, 7, 5), DateTime(2026, 7, 6)), 1);
      expect(monthsRoundedUp(DateTime(2026, 7, 5), DateTime(2026, 10, 27)), 4);
      expect(monthsRoundedUp(DateTime(2026, 1, 31), DateTime(2026, 2, 28)), 1);
    });

    test('Urea ₹1,200 from 05-Jul to 27-Oct counts 4 months → ₹96', () {
      final sheet = exampleSheet()..dayCount = DayCount.partMonthIsFull;
      expect(sheet.resultFor(sheet.purchases[0]).interest, closeTo(96, 0.001));
    });
  });

  test('paddy needed hides when there is no price', () {
    expect(CreditSheet.paddyNeeded(5954, null), isNull);
    expect(CreditSheet.paddyNeeded(5954, 2300), closeTo(2.59, 0.01));
  });

  test('save and load keeps everything', () {
    final sheet = exampleSheet()..setSamePaybackForAll(false);
    final copy = CreditSheet.fromJson(sheet.toJson());
    expect(copy.purchases.length, 3);
    expect(copy.samePaybackForAll, isFalse);
    expect(copy.summary().totalInterest.round(), 354);
  });
}
