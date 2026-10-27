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

  @override
  String get navToday => 'ఈరోజు';

  @override
  String get navCredit => 'అప్పు లెక్క';

  @override
  String get priceCardTitle => 'వడ్ల ధర';

  @override
  String get perQuintal => 'క్వింటాల్‌కు';

  @override
  String priceMinMax(String min, String max) {
    return 'కనిష్ఠ $min · గరిష్ఠ $max';
  }

  @override
  String priceUp(String amount) {
    return '$amount పెరిగింది';
  }

  @override
  String priceDown(String amount) {
    return '$amount తగ్గింది';
  }

  @override
  String get priceSame => 'మార్పు లేదు';

  @override
  String priceComparedTo(String date) {
    return '$date తో పోలిస్తే';
  }

  @override
  String priceOfDate(String date) {
    return '$date నాటి ధర';
  }

  @override
  String marketName(String market) {
    return '$market మార్కెట్';
  }

  @override
  String get otherVarieties => 'ఇతర రకాలు';

  @override
  String mspTitle(String season) {
    return 'కనీస మద్దతు ధర $season';
  }

  @override
  String get mspCommon => 'సాధారణం';

  @override
  String get mspGradeA => 'గ్రేడ్ A';

  @override
  String get noPriceData => 'ఈ రకానికి ఇంకా ధర రాలేదు';

  @override
  String get damCardTitle => 'ఆనకట్ట నీటి మట్టం';

  @override
  String get damNarayanpur => 'నారాయణపుర (బసవసాగర్)';

  @override
  String get damAlmatti => 'ఆలమట్టి';

  @override
  String get damFull => 'నిండింది';

  @override
  String get damLevel => 'నీటి మట్టం';

  @override
  String get damFullLevel => 'పూర్తి మట్టం';

  @override
  String get damStorage => 'నిల్వ';

  @override
  String get damInflow => 'లోపలికి వస్తున్న నీరు';

  @override
  String get damOutflow => 'బయటికి వదిలే నీరు';

  @override
  String metres(String value) {
    return '$value మీ.';
  }

  @override
  String tmc(String value) {
    return '$value TMC';
  }

  @override
  String cusecs(String value) {
    return '$value క్యూసెక్కులు';
  }

  @override
  String get noDamData => 'ఇంకా ఆనకట్ట సమాచారం రాలేదు';

  @override
  String get damManual => 'చేతితో నమోదు చేసినది';

  @override
  String dataDate(String date) {
    return '$date నాటి సమాచారం';
  }

  @override
  String get rainCardTitle => 'వర్ష సూచన';

  @override
  String get rainNow => 'ఇప్పుడు';

  @override
  String get rainRestOfToday => 'ఈరోజు మిగతా సమయం';

  @override
  String rainChance(int value) {
    return 'వర్షం అవకాశం $value%';
  }

  @override
  String millimetres(String value) {
    return '$value మి.మీ.';
  }

  @override
  String get rainNone => 'ఈరోజు వర్షం పడే అవకాశం లేదు';

  @override
  String get rainSmall => 'ఈరోజు కొద్దిగా వర్షం పడవచ్చు';

  @override
  String rainLikely(String time) {
    return '$time తర్వాత వర్షం పడే అవకాశం ఉంది';
  }

  @override
  String rainHeavy(String time) {
    return '$time తర్వాత భారీ వర్షం పడే అవకాశం ఉంది';
  }

  @override
  String get rainLikelyToday => 'ఈరోజు వర్షం పడే అవకాశం ఉంది';

  @override
  String get rainHeavyToday => 'ఈరోజు భారీ వర్షం పడే అవకాశం ఉంది';

  @override
  String hourMorning(int h) {
    return 'ఉదయం $h';
  }

  @override
  String hourNoon(int h) {
    return 'మధ్యాహ్నం $h';
  }

  @override
  String hourEvening(int h) {
    return 'సాయంత్రం $h';
  }

  @override
  String hourNightPm(int h) {
    return 'రాత్రి $h';
  }

  @override
  String hourNightAm(int h) {
    return 'రాత్రి $h';
  }

  @override
  String get nextDays => 'రాబోయే రోజులు';

  @override
  String updatedAt(String time) {
    return '$time కి తాజా సమాచారం';
  }

  @override
  String get staleData => 'పాత సమాచారం – కొత్తది ఇంకా రాలేదు';

  @override
  String get noDataYet =>
      'ఇంకా సమాచారం రాలేదు. ఇంటర్నెట్ ఆన్ చేసి, పై నుండి కిందికి లాగండి.';

  @override
  String get refreshFailed => 'ఇంటర్నెట్ అందలేదు. దాచిన సమాచారం చూపిస్తున్నాం.';

  @override
  String get refreshNoChange => 'కొత్త సమాచారం లేదు';

  @override
  String get refreshUpdated => 'కొత్త సమాచారం వచ్చింది';

  @override
  String get myVariety => 'నా వడ్ల రకం';

  @override
  String get myMarket => 'నా మార్కెట్';

  @override
  String get varietySonaMasuri => 'సోనా మసూరి';

  @override
  String get varietyRnr => 'ఆర్‌ఎన్‌ఆర్';

  @override
  String get varietyBpt => 'బీపీటీ';
}
