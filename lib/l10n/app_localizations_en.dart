// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeMessage => 'Welcome';

  @override
  String get appName => 'Nari Udyam';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get inventory => 'Inventory';

  @override
  String get schedule => 'Schedule';

  @override
  String get customerOrder => 'Customer Order';

  @override
  String get profile => 'Profile';

  @override
  String get home => 'Home';

  @override
  String get order => 'Order';

  @override
  String get newService => 'New Service';

  @override
  String get serviceName => 'Service Name';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get description => 'Description';

  @override
  String get price => 'Price';

  @override
  String get enterPrice => 'Enter price';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get durationMinutes => 'Duration (minutes)';

  @override
  String get enterDuration => 'Enter duration';

  @override
  String get saveService => 'Save Service';

  @override
  String get noServicesFound => 'No services found.';

  @override
  String get noProductsFound => 'No products found.';

  @override
  String get add => 'Add';

  @override
  String errorLoadingData(Object error) {
    return 'Error loading data: $error';
  }

  @override
  String errorFetchingItem(Object error) {
    return 'Error: $error';
  }

  @override
  String get sell => 'Sell';

  @override
  String get amount => 'Amount';

  @override
  String get reorderThreshold => 'Reorder Threshold';

  @override
  String get locations => 'Locations';

  @override
  String get stockValue => 'Stock value';

  @override
  String get lastPurchased => 'Last purchased';

  @override
  String get lastSold => 'Last Sold';

  @override
  String get lastPrice => 'Last price';

  @override
  String get averagePrice => 'Average price';

  @override
  String get per => 'per';

  @override
  String get notAvailable => 'N/A';

  @override
  String get sellItem => 'Sell Item';

  @override
  String get quantityToSell => 'Quantity to sell';

  @override
  String get pleaseEnterQuantity => 'Please enter a quantity';

  @override
  String get pleaseEnterValidPositiveNumber =>
      'Please enter a valid positive number';

  @override
  String notEnoughStock(Object stockQuantity) {
    return 'Not enough stock. Available: $stockQuantity';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get failedToUpdateInventory =>
      'Failed to update inventory or record transaction.';

  @override
  String get addInventoryItem => 'Add Inventory Item';

  @override
  String get noInventoryItemsFound => 'No inventory items found. Add some!';

  @override
  String errorFetchingInventoryItems(Object error) {
    return 'Error: $error';
  }

  @override
  String get selectLanguage => 'Select Language';

  @override
  String languageUpdated(Object lang) {
    return 'Language updated to $lang';
  }

  @override
  String get user => 'User';

  @override
  String get businessInformation => 'Business Information';

  @override
  String get businessName => 'Business Name';

  @override
  String get businessDomain => 'Business Domain';

  @override
  String get settings => 'Settings';

  @override
  String get languages => 'Languages';

  @override
  String get notifications => 'Notifications';

  @override
  String get favouriteCustomers => 'Favourite Customers';

  @override
  String get financialTransactions => 'Financial Transactions';

  @override
  String get exportTransactionsToExcel => 'Export Transactions to Excel';

  @override
  String get transactionsExported => 'Transactions exported to Excel!';

  @override
  String get exportOnboardingDataToExcel => 'Export Onboarding Data to Excel';

  @override
  String get onboardingDataExported => 'Onboarding data exported to Excel!';

  @override
  String get signOut => 'Sign Out';

  @override
  String get today => 'Today';

  @override
  String get best => 'Best';

  @override
  String get total => 'Total';

  @override
  String get revenue => 'Revenue';

  @override
  String get expenses => 'Expenses';
}
