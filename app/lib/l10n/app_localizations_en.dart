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

  @override
  String get navToday => 'Today';

  @override
  String get navCredit => 'Credit';

  @override
  String get priceCardTitle => 'Paddy price';

  @override
  String get perQuintal => 'per quintal';

  @override
  String priceMinMax(String min, String max) {
    return 'Min $min · Max $max';
  }

  @override
  String priceUp(String amount) {
    return 'Up $amount';
  }

  @override
  String priceDown(String amount) {
    return 'Down $amount';
  }

  @override
  String get priceSame => 'No change';

  @override
  String priceComparedTo(String date) {
    return 'compared to $date';
  }

  @override
  String priceOfDate(String date) {
    return 'Price of $date';
  }

  @override
  String marketName(String market) {
    return '$market market';
  }

  @override
  String get otherVarieties => 'Other varieties';

  @override
  String mspTitle(String season) {
    return 'MSP $season';
  }

  @override
  String get mspCommon => 'Common';

  @override
  String get mspGradeA => 'Grade A';

  @override
  String get noPriceData => 'No price for this variety yet';

  @override
  String get damCardTitle => 'Dam water level';

  @override
  String get damNarayanpur => 'Narayanpur (Basavasagar)';

  @override
  String get damAlmatti => 'Almatti';

  @override
  String get damFull => 'full';

  @override
  String get damLevel => 'Water level';

  @override
  String get damFullLevel => 'Full level';

  @override
  String get damStorage => 'Storage';

  @override
  String get damInflow => 'Inflow';

  @override
  String get damOutflow => 'Outflow';

  @override
  String metres(String value) {
    return '$value m';
  }

  @override
  String tmc(String value) {
    return '$value TMC';
  }

  @override
  String cusecs(String value) {
    return '$value cusecs';
  }

  @override
  String get noDamData => 'No dam data yet';

  @override
  String get damManual => 'Entered by hand';

  @override
  String dataDate(String date) {
    return 'Data of $date';
  }

  @override
  String get rainCardTitle => 'Rain forecast';

  @override
  String get rainNow => 'Now';

  @override
  String get rainRestOfToday => 'Rest of today';

  @override
  String rainChance(int value) {
    return '$value% chance of rain';
  }

  @override
  String millimetres(String value) {
    return '$value mm';
  }

  @override
  String get rainNone => 'No rain expected today';

  @override
  String get rainSmall => 'Small chance of rain today';

  @override
  String rainLikely(String time) {
    return 'Rain likely after $time';
  }

  @override
  String rainHeavy(String time) {
    return 'Heavy rain likely after $time';
  }

  @override
  String get rainLikelyToday => 'Rain likely today';

  @override
  String get rainHeavyToday => 'Heavy rain likely today';

  @override
  String hourMorning(int h) {
    return '$h AM';
  }

  @override
  String hourNoon(int h) {
    return '$h PM';
  }

  @override
  String hourEvening(int h) {
    return '$h PM';
  }

  @override
  String hourNightPm(int h) {
    return '$h PM';
  }

  @override
  String hourNightAm(int h) {
    return '$h AM';
  }

  @override
  String get nextDays => 'Next days';

  @override
  String updatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String get staleData => 'Old data – no new update yet';

  @override
  String get noDataYet =>
      'No data yet. Turn on the internet and pull down to refresh.';

  @override
  String get refreshFailed => 'Could not connect. Showing saved data.';

  @override
  String get refreshNoChange => 'Nothing new yet';

  @override
  String get refreshUpdated => 'Updated';

  @override
  String get myVariety => 'My paddy variety';

  @override
  String get myMarket => 'My market';

  @override
  String get varietySonaMasuri => 'Sona Masuri';

  @override
  String get varietyRnr => 'RNR';

  @override
  String get varietyBpt => 'BPT';
}
