import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('hi'),
    Locale('te')
  ];

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeMessage;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NariUdyam'**
  String get appName;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @customerOrder.
  ///
  /// In en, this message translates to:
  /// **'Customer Order'**
  String get customerOrder;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @newService.
  ///
  /// In en, this message translates to:
  /// **'New Service'**
  String get newService;

  /// No description provided for @serviceName.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get serviceName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationMinutes;

  /// No description provided for @enterDuration.
  ///
  /// In en, this message translates to:
  /// **'Enter duration'**
  String get enterDuration;

  /// No description provided for @saveService.
  ///
  /// In en, this message translates to:
  /// **'Save Service'**
  String get saveService;

  /// No description provided for @noServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found.'**
  String get noServicesFound;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get noProductsFound;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(Object error);

  /// No description provided for @errorFetchingItem.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorFetchingItem(Object error);

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @reorderThreshold.
  ///
  /// In en, this message translates to:
  /// **'Reorder Threshold'**
  String get reorderThreshold;

  /// No description provided for @locations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get locations;

  /// No description provided for @stockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock value'**
  String get stockValue;

  /// No description provided for @lastPurchased.
  ///
  /// In en, this message translates to:
  /// **'Last purchased'**
  String get lastPurchased;

  /// No description provided for @lastSold.
  ///
  /// In en, this message translates to:
  /// **'Last Sold'**
  String get lastSold;

  /// No description provided for @lastPrice.
  ///
  /// In en, this message translates to:
  /// **'Last price'**
  String get lastPrice;

  /// No description provided for @averagePrice.
  ///
  /// In en, this message translates to:
  /// **'Average price'**
  String get averagePrice;

  /// No description provided for @per.
  ///
  /// In en, this message translates to:
  /// **'per'**
  String get per;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @sellItem.
  ///
  /// In en, this message translates to:
  /// **'Sell Item'**
  String get sellItem;

  /// No description provided for @quantityToSell.
  ///
  /// In en, this message translates to:
  /// **'Quantity to sell'**
  String get quantityToSell;

  /// No description provided for @pleaseEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quantity'**
  String get pleaseEnterQuantity;

  /// No description provided for @pleaseEnterValidPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive number'**
  String get pleaseEnterValidPositiveNumber;

  /// No description provided for @notEnoughStock.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock. Available: {stockQuantity}'**
  String notEnoughStock(Object stockQuantity);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @failedToUpdateInventory.
  ///
  /// In en, this message translates to:
  /// **'Failed to update inventory or record transaction.'**
  String get failedToUpdateInventory;

  /// No description provided for @addInventoryItem.
  ///
  /// In en, this message translates to:
  /// **'Add Inventory Item'**
  String get addInventoryItem;

  /// No description provided for @noInventoryItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No inventory items found. Add some!'**
  String get noInventoryItemsFound;

  /// No description provided for @errorFetchingInventoryItems.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorFetchingInventoryItems(Object error);

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated to {lang}'**
  String languageUpdated(Object lang);

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @businessInformation.
  ///
  /// In en, this message translates to:
  /// **'Business Information'**
  String get businessInformation;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @businessDomain.
  ///
  /// In en, this message translates to:
  /// **'Business Domain'**
  String get businessDomain;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @favouriteCustomers.
  ///
  /// In en, this message translates to:
  /// **'Favourite Customers'**
  String get favouriteCustomers;

  /// No description provided for @financialTransactions.
  ///
  /// In en, this message translates to:
  /// **'Financial Transactions'**
  String get financialTransactions;

  /// No description provided for @exportTransactionsToExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Transactions to Excel'**
  String get exportTransactionsToExcel;

  /// No description provided for @transactionsExported.
  ///
  /// In en, this message translates to:
  /// **'Transactions exported to Excel!'**
  String get transactionsExported;

  /// No description provided for @exportOnboardingDataToExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Onboarding Data to Excel'**
  String get exportOnboardingDataToExcel;

  /// No description provided for @onboardingDataExported.
  ///
  /// In en, this message translates to:
  /// **'Onboarding data exported to Excel!'**
  String get onboardingDataExported;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @best.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;
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
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
