import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te'),
  ];

  /// App name. Means 'the farmer is king'.
  ///
  /// In en, this message translates to:
  /// **'Raithe Raju'**
  String get appTitle;

  /// No description provided for @calculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer credit'**
  String get calculatorTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'Interest rate'**
  String get interestRate;

  /// No description provided for @ratePerHundredPerMonth.
  ///
  /// In en, this message translates to:
  /// **'₹ per ₹100 per month (shop rate)'**
  String get ratePerHundredPerMonth;

  /// No description provided for @ratePercentPerYear.
  ///
  /// In en, this message translates to:
  /// **'% per year (bank rate)'**
  String get ratePercentPerYear;

  /// No description provided for @samePaybackForAll.
  ///
  /// In en, this message translates to:
  /// **'Same payback date for all items'**
  String get samePaybackForAll;

  /// No description provided for @payingBackOn.
  ///
  /// In en, this message translates to:
  /// **'Paying back on'**
  String get payingBackOn;

  /// No description provided for @boughtOn.
  ///
  /// In en, this message translates to:
  /// **'Bought on'**
  String get boughtOn;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'What was bought'**
  String get itemName;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get amount;

  /// No description provided for @addPurchase.
  ///
  /// In en, this message translates to:
  /// **'Add purchase'**
  String get addPurchase;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get removed;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String days(int count);

  /// No description provided for @interest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get interest;

  /// No description provided for @itemTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get itemTotal;

  /// No description provided for @totalBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Total borrowed'**
  String get totalBorrowed;

  /// No description provided for @totalInterest.
  ///
  /// In en, this message translates to:
  /// **'Total interest'**
  String get totalInterest;

  /// No description provided for @amountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount to pay'**
  String get amountToPay;

  /// No description provided for @paddyNeeded.
  ///
  /// In en, this message translates to:
  /// **'Paddy needed to clear this debt'**
  String get paddyNeeded;

  /// No description provided for @quintals.
  ///
  /// In en, this message translates to:
  /// **'{value} quintals'**
  String quintals(String value);

  /// No description provided for @errAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount must be more than 0'**
  String get errAmount;

  /// No description provided for @errBoughtDate.
  ///
  /// In en, this message translates to:
  /// **'Choose the bought-on date'**
  String get errBoughtDate;

  /// No description provided for @errPaybackDate.
  ///
  /// In en, this message translates to:
  /// **'Choose the paying-back date'**
  String get errPaybackDate;

  /// No description provided for @errDateOrder.
  ///
  /// In en, this message translates to:
  /// **'Bought-on date can\'t be after the paying-back date'**
  String get errDateOrder;

  /// No description provided for @errRate.
  ///
  /// In en, this message translates to:
  /// **'Interest rate must be more than 0'**
  String get errRate;

  /// No description provided for @fixErrors.
  ///
  /// In en, this message translates to:
  /// **'Fix the items marked in red to see the total'**
  String get fixErrors;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'Nothing added yet. Tap the button below.'**
  String get emptyList;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @dayCountMethod.
  ///
  /// In en, this message translates to:
  /// **'How days are counted'**
  String get dayCountMethod;

  /// No description provided for @dayCountExact.
  ///
  /// In en, this message translates to:
  /// **'Exact days (30-day months)'**
  String get dayCountExact;

  /// No description provided for @dayCountPartMonth.
  ///
  /// In en, this message translates to:
  /// **'Any part of a month counts as a full month'**
  String get dayCountPartMonth;

  /// No description provided for @itemUrea.
  ///
  /// In en, this message translates to:
  /// **'Urea'**
  String get itemUrea;

  /// No description provided for @itemDap.
  ///
  /// In en, this message translates to:
  /// **'DAP'**
  String get itemDap;

  /// No description provided for @itemPotash.
  ///
  /// In en, this message translates to:
  /// **'Potash'**
  String get itemPotash;

  /// No description provided for @itemPesticide.
  ///
  /// In en, this message translates to:
  /// **'Pesticide'**
  String get itemPesticide;

  /// No description provided for @itemSeeds.
  ///
  /// In en, this message translates to:
  /// **'Seeds'**
  String get itemSeeds;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get navCredit;

  /// No description provided for @priceCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Paddy price'**
  String get priceCardTitle;

  /// No description provided for @perQuintal.
  ///
  /// In en, this message translates to:
  /// **'per quintal'**
  String get perQuintal;

  /// No description provided for @priceMinMax.
  ///
  /// In en, this message translates to:
  /// **'Min {min} · Max {max}'**
  String priceMinMax(String min, String max);

  /// No description provided for @priceUp.
  ///
  /// In en, this message translates to:
  /// **'Up {amount}'**
  String priceUp(String amount);

  /// No description provided for @priceDown.
  ///
  /// In en, this message translates to:
  /// **'Down {amount}'**
  String priceDown(String amount);

  /// No description provided for @priceSame.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get priceSame;

  /// No description provided for @priceComparedTo.
  ///
  /// In en, this message translates to:
  /// **'compared to {date}'**
  String priceComparedTo(String date);

  /// No description provided for @priceOfDate.
  ///
  /// In en, this message translates to:
  /// **'Price of {date}'**
  String priceOfDate(String date);

  /// No description provided for @marketName.
  ///
  /// In en, this message translates to:
  /// **'{market} market'**
  String marketName(String market);

  /// No description provided for @otherVarieties.
  ///
  /// In en, this message translates to:
  /// **'Other varieties'**
  String get otherVarieties;

  /// No description provided for @mspTitle.
  ///
  /// In en, this message translates to:
  /// **'MSP {season}'**
  String mspTitle(String season);

  /// No description provided for @mspCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get mspCommon;

  /// No description provided for @mspGradeA.
  ///
  /// In en, this message translates to:
  /// **'Grade A'**
  String get mspGradeA;

  /// No description provided for @noPriceData.
  ///
  /// In en, this message translates to:
  /// **'No price for this variety yet'**
  String get noPriceData;

  /// No description provided for @damCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dam water level'**
  String get damCardTitle;

  /// No description provided for @damNarayanpur.
  ///
  /// In en, this message translates to:
  /// **'Narayanpur (Basavasagar)'**
  String get damNarayanpur;

  /// No description provided for @damAlmatti.
  ///
  /// In en, this message translates to:
  /// **'Almatti'**
  String get damAlmatti;

  /// No description provided for @damFull.
  ///
  /// In en, this message translates to:
  /// **'full'**
  String get damFull;

  /// No description provided for @damLevel.
  ///
  /// In en, this message translates to:
  /// **'Water level'**
  String get damLevel;

  /// No description provided for @damFullLevel.
  ///
  /// In en, this message translates to:
  /// **'Full level'**
  String get damFullLevel;

  /// No description provided for @damStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get damStorage;

  /// No description provided for @damInflow.
  ///
  /// In en, this message translates to:
  /// **'Inflow'**
  String get damInflow;

  /// No description provided for @damOutflow.
  ///
  /// In en, this message translates to:
  /// **'Outflow'**
  String get damOutflow;

  /// No description provided for @metres.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String metres(String value);

  /// No description provided for @tmc.
  ///
  /// In en, this message translates to:
  /// **'{value} TMC'**
  String tmc(String value);

  /// No description provided for @cusecs.
  ///
  /// In en, this message translates to:
  /// **'{value} cusecs'**
  String cusecs(String value);

  /// No description provided for @noDamData.
  ///
  /// In en, this message translates to:
  /// **'No dam data yet'**
  String get noDamData;

  /// No description provided for @damManual.
  ///
  /// In en, this message translates to:
  /// **'Entered by hand'**
  String get damManual;

  /// No description provided for @dataDate.
  ///
  /// In en, this message translates to:
  /// **'Data of {date}'**
  String dataDate(String date);

  /// No description provided for @rainCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Rain forecast'**
  String get rainCardTitle;

  /// No description provided for @rainNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get rainNow;

  /// No description provided for @rainRestOfToday.
  ///
  /// In en, this message translates to:
  /// **'Rest of today'**
  String get rainRestOfToday;

  /// No description provided for @rainChance.
  ///
  /// In en, this message translates to:
  /// **'{value}% chance of rain'**
  String rainChance(int value);

  /// No description provided for @millimetres.
  ///
  /// In en, this message translates to:
  /// **'{value} mm'**
  String millimetres(String value);

  /// No description provided for @rainNone.
  ///
  /// In en, this message translates to:
  /// **'No rain expected today'**
  String get rainNone;

  /// No description provided for @rainSmall.
  ///
  /// In en, this message translates to:
  /// **'Small chance of rain today'**
  String get rainSmall;

  /// No description provided for @rainLikely.
  ///
  /// In en, this message translates to:
  /// **'Rain likely after {time}'**
  String rainLikely(String time);

  /// No description provided for @rainHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain likely after {time}'**
  String rainHeavy(String time);

  /// No description provided for @rainLikelyToday.
  ///
  /// In en, this message translates to:
  /// **'Rain likely today'**
  String get rainLikelyToday;

  /// No description provided for @rainHeavyToday.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain likely today'**
  String get rainHeavyToday;

  /// No description provided for @hourMorning.
  ///
  /// In en, this message translates to:
  /// **'{h} AM'**
  String hourMorning(int h);

  /// No description provided for @hourNoon.
  ///
  /// In en, this message translates to:
  /// **'{h} PM'**
  String hourNoon(int h);

  /// No description provided for @hourEvening.
  ///
  /// In en, this message translates to:
  /// **'{h} PM'**
  String hourEvening(int h);

  /// No description provided for @hourNightPm.
  ///
  /// In en, this message translates to:
  /// **'{h} PM'**
  String hourNightPm(int h);

  /// No description provided for @hourNightAm.
  ///
  /// In en, this message translates to:
  /// **'{h} AM'**
  String hourNightAm(int h);

  /// No description provided for @nextDays.
  ///
  /// In en, this message translates to:
  /// **'Next days'**
  String get nextDays;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updatedAt(String time);

  /// No description provided for @staleData.
  ///
  /// In en, this message translates to:
  /// **'Old data – no new update yet'**
  String get staleData;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet. Turn on the internet and pull down to refresh.'**
  String get noDataYet;

  /// No description provided for @refreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Showing saved data.'**
  String get refreshFailed;

  /// No description provided for @refreshNoChange.
  ///
  /// In en, this message translates to:
  /// **'Nothing new yet'**
  String get refreshNoChange;

  /// No description provided for @refreshUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get refreshUpdated;

  /// No description provided for @myVariety.
  ///
  /// In en, this message translates to:
  /// **'My paddy variety'**
  String get myVariety;

  /// No description provided for @myMarket.
  ///
  /// In en, this message translates to:
  /// **'My market'**
  String get myMarket;

  /// No description provided for @varietySonaMasuri.
  ///
  /// In en, this message translates to:
  /// **'Sona Masuri'**
  String get varietySonaMasuri;

  /// No description provided for @varietyRnr.
  ///
  /// In en, this message translates to:
  /// **'RNR'**
  String get varietyRnr;

  /// No description provided for @varietyBpt.
  ///
  /// In en, this message translates to:
  /// **'BPT'**
  String get varietyBpt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
