import 'package:intl/intl.dart';

// Shared number and date formats, so every screen looks the same.

/// ₹1,00,000 style (Indian grouping), rounded to the nearest rupee.
String rupees(double value) => NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
).format(value.round());

/// e.g. "27 అక్టో 2026" in Telugu, "27 Oct 2026" in English.
String shortDate(DateTime date, String languageCode) =>
    DateFormat('d MMM yyyy', languageCode).format(date);
