// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Raithe Raju';

  @override
  String get calculatorTitle => 'Fertilizer credit';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get interestRate => 'Interest rate';

  @override
  String get ratePerHundredPerMonth => '₹ per ₹100 per month (shop rate)';

  @override
  String get ratePercentPerYear => '% per year (bank rate)';

  @override
  String get samePaybackForAll => 'Same payback date for all items';

  @override
  String get payingBackOn => 'Paying back on';

  @override
  String get boughtOn => 'Bought on';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get itemName => 'What was bought';

  @override
  String get amount => 'Amount (₹)';

  @override
  String get addPurchase => 'Add purchase';

  @override
  String get delete => 'Delete';

  @override
  String get removed => 'Removed';

  @override
  String get undo => 'Undo';

  @override
  String days(int count) {
    return '$count days';
  }

  @override
  String get interest => 'Interest';

  @override
  String get itemTotal => 'Total';

  @override
  String get totalBorrowed => 'Total borrowed';

  @override
  String get totalInterest => 'Total interest';

  @override
  String get amountToPay => 'Amount to pay';

  @override
  String get paddyNeeded => 'Paddy needed to clear this debt';

  @override
  String quintals(String value) {
    return '$value quintals';
  }

  @override
  String get errAmount => 'Amount must be more than 0';

  @override
  String get errBoughtDate => 'Choose the bought-on date';

  @override
  String get errPaybackDate => 'Choose the paying-back date';

  @override
  String get errDateOrder =>
      'Bought-on date can\'t be after the paying-back date';

  @override
  String get errRate => 'Interest rate must be more than 0';

  @override
  String get fixErrors => 'Fix the items marked in red to see the total';

  @override
  String get emptyList => 'Nothing added yet. Tap the button below.';

  @override
  String get language => 'Language';

  @override
  String get dayCountMethod => 'How days are counted';

  @override
  String get dayCountExact => 'Exact days (30-day months)';

  @override
  String get dayCountPartMonth => 'Any part of a month counts as a full month';

  @override
  String get itemUrea => 'Urea';

  @override
  String get itemDap => 'DAP';

  @override
  String get itemPotash => 'Potash';

  @override
  String get itemPesticide => 'Pesticide';

  @override
  String get itemSeeds => 'Seeds';
}
