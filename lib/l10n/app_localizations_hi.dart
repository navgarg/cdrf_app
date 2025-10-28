// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get welcomeMessage => 'स्वागत है';

  @override
  String get appName => 'NariUdyam';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get inventory => 'सूची';

  @override
  String get schedule => 'अनुसूची';

  @override
  String get customerOrder => 'ग्राहक आदेश';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get home => 'मुखपृष्ठ';

  @override
  String get order => 'आदेश';

  @override
  String get newService => 'नई सेवा';

  @override
  String get serviceName => 'सेवा का नाम';

  @override
  String get pleaseEnterName => 'कृपया नाम दर्ज करें';

  @override
  String get description => 'विवरण';

  @override
  String get price => 'मूल्य';

  @override
  String get enterPrice => 'मूल्य दर्ज करें';

  @override
  String get invalidNumber => 'अमान्य संख्या';

  @override
  String get durationMinutes => 'अवधि (मिनटों में)';

  @override
  String get enterDuration => 'अवधि दर्ज करें';

  @override
  String get saveService => 'सेवा सहेजें';

  @override
  String get noServicesFound => 'कोई सेवाएं नहीं मिलीं।';

  @override
  String get noProductsFound => 'कोई उत्पाद नहीं मिला।';

  @override
  String get add => 'जोड़ें';

  @override
  String errorLoadingData(Object error) {
    return 'डेटा लोड करने में त्रुटि: $error';
  }

  @override
  String errorFetchingItem(Object error) {
    return 'त्रुटि: $error';
  }

  @override
  String get sell => 'बेचें';

  @override
  String get amount => 'राशि';

  @override
  String get reorderThreshold => 'पुनः आदेश सीमा';

  @override
  String get locations => 'स्थान';

  @override
  String get stockValue => 'भंडार मूल्य';

  @override
  String get lastPurchased => 'अंतिम बार खरीदा गया';

  @override
  String get lastSold => 'अंतिम बार बेचा गया';

  @override
  String get lastPrice => 'अंतिम मूल्य';

  @override
  String get averagePrice => 'औसत मूल्य';

  @override
  String get per => 'प्रति';

  @override
  String get notAvailable => 'उपलब्ध नहीं';

  @override
  String get sellItem => 'वस्तु बेचें';

  @override
  String get quantityToSell => 'बेचने की मात्रा';

  @override
  String get pleaseEnterQuantity => 'कृपया मात्रा दर्ज करें';

  @override
  String get pleaseEnterValidPositiveNumber =>
      'कृपया मान्य धनात्मक संख्या दर्ज करें';

  @override
  String notEnoughStock(Object stockQuantity) {
    return 'पर्याप्त भंडार नहीं है। उपलब्ध: $stockQuantity';
  }

  @override
  String get cancel => 'रद्द करें';

  @override
  String get failedToUpdateInventory =>
      'सूची अपडेट करने या लेनदेन दर्ज करने में विफल।';

  @override
  String get addInventoryItem => 'सूची में वस्तु जोड़ें';

  @override
  String get noInventoryItemsFound => 'कोई सूची आइटम नहीं मिले। कुछ जोड़ें!';

  @override
  String errorFetchingInventoryItems(Object error) {
    return 'त्रुटि: $error';
  }

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String languageUpdated(Object lang) {
    return 'भाषा $lang में अपडेट की गई';
  }

  @override
  String get user => 'उपयोगकर्ता';

  @override
  String get businessInformation => 'व्यवसाय की जानकारी';

  @override
  String get businessName => 'व्यवसाय का नाम';

  @override
  String get businessDomain => 'व्यवसाय क्षेत्र';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get languages => 'भाषाएँ';

  @override
  String get notifications => 'सूचनाएँ';

  @override
  String get favouriteCustomers => 'पसंदीदा ग्राहक';

  @override
  String get financialTransactions => 'वित्तीय लेनदेन';

  @override
  String get exportTransactionsToExcel => 'लेनदेन को एक्सेल में निर्यात करें';

  @override
  String get transactionsExported => 'लेनदेन एक्सेल में निर्यात किए गए!';

  @override
  String get exportOnboardingDataToExcel =>
      'ऑनबोर्डिंग डेटा को एक्सेल में निर्यात करें';

  @override
  String get onboardingDataExported =>
      'ऑनबोर्डिंग डेटा एक्सेल में निर्यात किया गया!';

  @override
  String get signOut => 'साइन आउट करें';

  @override
  String get today => 'आज';

  @override
  String get best => 'सर्वश्रेष्ठ';

  @override
  String get total => 'कुल';

  @override
  String get revenue => 'राजस्व';

  @override
  String get expenses => 'खर्चे';
}
