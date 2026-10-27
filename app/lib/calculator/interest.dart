// Pure calculation logic for the fertilizer credit calculator.
//
// Nothing in this file touches the screen or storage, so every rule here
// can be checked by the unit tests in test/interest_test.dart.

/// How the shop quotes its interest rate.
enum RateType {
  /// "₹2 rate": rupees per ₹100 per month (how village shops quote it).
  perHundredPerMonth,

  /// "7%": percent per year (how banks quote it).
  percentPerYear,
}

/// How the number of days is turned into interest.
enum DayCount {
  /// Exact days, with every month counted as 30 days (default).
  exactDays,

  /// Any part of a month counts as a full month.
  partMonthIsFull,
}

/// Problems that stop one purchase from being calculated.
enum PurchaseError {
  amountNotPositive,
  missingBoughtDate,
  missingPaybackDate,
  boughtAfterPayback,
}

/// One thing bought on credit, e.g. "Urea ₹1,200 on 5 July".
class Purchase {
  Purchase({
    required this.id,
    this.name = '',
    this.amount = 0,
    this.boughtOn,
    this.paybackOn,
  });

  /// Unique id so the screen can tell items apart.
  final String id;
  String name;

  /// Amount in rupees.
  double amount;
  DateTime? boughtOn;

  /// Only used when "same payback date for all items" is OFF.
  DateTime? paybackOn;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'boughtOn': boughtOn?.toIso8601String(),
    'paybackOn': paybackOn?.toIso8601String(),
  };

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? '',
    amount: ((json['amount'] as num?) ?? 0).toDouble(),
    boughtOn: _parseDate(json['boughtOn']),
    paybackOn: _parseDate(json['paybackOn']),
  );
}

DateTime? _parseDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

/// Result for one purchase. If [error] is set, the numbers are zero.
class PurchaseResult {
  const PurchaseResult({
    this.error,
    this.days = 0,
    this.interest = 0,
    this.total = 0,
  });

  final PurchaseError? error;
  final int days;
  final double interest;

  /// Amount + interest.
  final double total;

  bool get isValid => error == null;
}

/// Totals for the whole list. [hasErrors] means at least one item needs
/// fixing, and the screen must not show a total that leaves it out.
class SheetSummary {
  const SheetSummary({
    required this.totalBorrowed,
    required this.totalInterest,
    required this.amountToPay,
    required this.hasErrors,
  });

  final double totalBorrowed;
  final double totalInterest;
  final double amountToPay;
  final bool hasErrors;
}

/// Whole days between two calendar dates, ignoring the time of day.
int daysBetween(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

/// Calendar months between two dates, where any extra part of a month
/// counts as one more month. 5 Jul → 5 Aug is 1; 5 Jul → 6 Aug is 2.
int monthsRoundedUp(DateTime from, DateTime to) {
  var months = (to.year - from.year) * 12 + (to.month - from.month);
  if (to.day < from.day) months -= 1; // last month not complete yet
  // Date reached after adding the full months.
  final reached = _addMonths(from, months);
  if (daysBetween(reached, to) > 0) months += 1;
  return months < 0 ? 0 : months;
}

DateTime _addMonths(DateTime date, int months) {
  final y = date.year + (date.month - 1 + months) ~/ 12;
  final m = (date.month - 1 + months) % 12 + 1;
  // Clamp the day, e.g. 31 Jan + 1 month → 28/29 Feb.
  final lastDay = DateTime.utc(y, m + 1, 0).day;
  final d = date.day > lastDay ? lastDay : date.day;
  return DateTime.utc(y, m, d);
}

/// Simple interest for one amount over a date range.
double simpleInterest({
  required double amount,
  required double rate,
  required RateType rateType,
  required DayCount dayCount,
  required DateTime from,
  required DateTime to,
}) {
  if (dayCount == DayCount.exactDays) {
    final days = daysBetween(from, to);
    return rateType == RateType.perHundredPerMonth
        ? amount * rate / 100 * days / 30
        : amount * rate / 100 * days / 365;
  }
  final months = monthsRoundedUp(from, to);
  return rateType == RateType.perHundredPerMonth
      ? amount * rate / 100 * months
      : amount * rate / 100 * months / 12;
}

/// Everything on the calculator screen: the rate, the payback date
/// setting and the list of purchases.
class CreditSheet {
  CreditSheet({
    this.rate = 2,
    this.rateType = RateType.perHundredPerMonth,
    this.dayCount = DayCount.exactDays,
    this.samePaybackForAll = true,
    this.commonPaybackOn,
    List<Purchase>? purchases,
  }) : purchases = purchases ?? [];

  double rate;
  RateType rateType;
  DayCount dayCount;
  bool samePaybackForAll;
  DateTime? commonPaybackOn;
  final List<Purchase> purchases;

  /// Turns the "same payback date for all items" switch on or off.
  ///
  /// OFF: each item gets its own date, pre-filled with the common date.
  /// ON: every item goes back to the common date.
  void setSamePaybackForAll(bool value) {
    samePaybackForAll = value;
    for (final p in purchases) {
      p.paybackOn = commonPaybackOn;
    }
  }

  /// The payback date that actually applies to [p].
  DateTime? paybackFor(Purchase p) =>
      samePaybackForAll ? commonPaybackOn : p.paybackOn;

  PurchaseResult resultFor(Purchase p) {
    final payback = paybackFor(p);
    if (p.amount <= 0) {
      return const PurchaseResult(error: PurchaseError.amountNotPositive);
    }
    if (p.boughtOn == null) {
      return const PurchaseResult(error: PurchaseError.missingBoughtDate);
    }
    if (payback == null) {
      return const PurchaseResult(error: PurchaseError.missingPaybackDate);
    }
    final days = daysBetween(p.boughtOn!, payback);
    if (days < 0) {
      return const PurchaseResult(error: PurchaseError.boughtAfterPayback);
    }
    final interest = simpleInterest(
      amount: p.amount,
      rate: rate,
      rateType: rateType,
      dayCount: dayCount,
      from: p.boughtOn!,
      to: payback,
    );
    return PurchaseResult(
      days: days,
      interest: interest,
      total: p.amount + interest,
    );
  }

  SheetSummary summary() {
    var borrowed = 0.0;
    var interest = 0.0;
    var hasErrors = false;
    for (final p in purchases) {
      final r = resultFor(p);
      if (!r.isValid) {
        hasErrors = true;
        continue;
      }
      borrowed += p.amount;
      interest += r.interest;
    }
    return SheetSummary(
      totalBorrowed: borrowed,
      totalInterest: interest,
      amountToPay: borrowed + interest,
      hasErrors: hasErrors,
    );
  }

  /// Quintals of paddy needed to pay [amountToPay] at [pricePerQuintal].
  /// Returns null when there is no price yet, so the screen hides the line.
  static double? paddyNeeded(double amountToPay, double? pricePerQuintal) {
    if (pricePerQuintal == null || pricePerQuintal <= 0) return null;
    return amountToPay / pricePerQuintal;
  }

  Map<String, dynamic> toJson() => {
    'rate': rate,
    'rateType': rateType.name,
    'dayCount': dayCount.name,
    'samePaybackForAll': samePaybackForAll,
    'commonPaybackOn': commonPaybackOn?.toIso8601String(),
    'purchases': purchases.map((p) => p.toJson()).toList(),
  };

  factory CreditSheet.fromJson(Map<String, dynamic> json) => CreditSheet(
    rate: ((json['rate'] as num?) ?? 2).toDouble(),
    rateType: RateType.values.firstWhere(
      (e) => e.name == json['rateType'],
      orElse: () => RateType.perHundredPerMonth,
    ),
    dayCount: DayCount.values.firstWhere(
      (e) => e.name == json['dayCount'],
      orElse: () => DayCount.exactDays,
    ),
    samePaybackForAll: (json['samePaybackForAll'] as bool?) ?? true,
    commonPaybackOn: _parseDate(json['commonPaybackOn']),
    purchases: ((json['purchases'] as List?) ?? [])
        .map((e) => Purchase.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}
