// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'రైతే రాజు';

  @override
  String get calculatorTitle => 'ఎరువుల అప్పు లెక్క';

  @override
  String get settingsTitle => 'సెట్టింగ్స్';

  @override
  String get interestRate => 'వడ్డీ రేటు';

  @override
  String get ratePerHundredPerMonth => '₹100 కి నెలకు ₹ (షాపు రేటు)';

  @override
  String get ratePercentPerYear => 'సంవత్సరానికి % (బ్యాంకు రేటు)';

  @override
  String get samePaybackForAll => 'అన్నిటికీ ఒకే తిరిగి కట్టే తేదీ';

  @override
  String get payingBackOn => 'తిరిగి కట్టే తేదీ';

  @override
  String get boughtOn => 'కొన్న తేదీ';

  @override
  String get chooseDate => 'తేదీ ఎంచుకోండి';

  @override
  String get itemName => 'ఏమి కొన్నారు';

  @override
  String get amount => 'ధర (₹)';

  @override
  String get addPurchase => 'కొత్త కొనుగోలు చేర్చు';

  @override
  String get delete => 'తీసివేయి';

  @override
  String get removed => 'తీసివేశాం';

  @override
  String get undo => 'వెనక్కి';

  @override
  String days(int count) {
    return '$count రోజులు';
  }

  @override
  String get interest => 'వడ్డీ';

  @override
  String get itemTotal => 'మొత్తం';

  @override
  String get totalBorrowed => 'తీసుకున్న అప్పు';

  @override
  String get totalInterest => 'మొత్తం వడ్డీ';

  @override
  String get amountToPay => 'కట్టాల్సిన మొత్తం';

  @override
  String get paddyNeeded => 'ఈ అప్పు తీర్చడానికి కావాల్సిన వడ్లు';

  @override
  String quintals(String value) {
    return '$value క్వింటాళ్లు';
  }

  @override
  String get errAmount => 'ధర 0 కంటే ఎక్కువ ఉండాలి';

  @override
  String get errBoughtDate => 'కొన్న తేదీ ఎంచుకోండి';

  @override
  String get errPaybackDate => 'తిరిగి కట్టే తేదీ ఎంచుకోండి';

  @override
  String get errDateOrder => 'కొన్న తేదీ, తిరిగి కట్టే తేదీ తర్వాత ఉండకూడదు';

  @override
  String get errRate => 'వడ్డీ రేటు 0 కంటే ఎక్కువ ఉండాలి';

  @override
  String get fixErrors => 'ఎరుపు గుర్తు ఉన్నవి సరిచేస్తే మొత్తం కనిపిస్తుంది';

  @override
  String get emptyList => 'ఇంకా ఏమీ చేర్చలేదు. కింద ఉన్న బటన్ నొక్కండి.';

  @override
  String get language => 'భాష';

  @override
  String get dayCountMethod => 'రోజుల లెక్క';

  @override
  String get dayCountExact => 'సరిగ్గా రోజులు (నెలకు 30 రోజులు)';

  @override
  String get dayCountPartMonth => 'నెలలో కొంచెం అయినా పూర్తి నెల';

  @override
  String get itemUrea => 'యూరియా';

  @override
  String get itemDap => 'డీఏపీ';

  @override
  String get itemPotash => 'పొటాష్';

  @override
  String get itemPesticide => 'పురుగు మందు';

  @override
  String get itemSeeds => 'విత్తనాలు';
}
