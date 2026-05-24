import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String phoneNumber;
  final String? name;
  final String? profilePicUrl;
  final String? deviceToken;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  final String? language;
  final String? education;
  final String? ageRange;
  final String? businessDomain;
  final String? respondentName;
  final String? age;
  final String? educationLevel;
  final String? yearsRunningBusiness;
  final String? numEmployees;
  final String? ownershipType;
  final String? digitalPayments;
  final String? socialMediaPromotion;
  final String? recordIncomeExpenses;
  final String? financialRecordsMethod;
  final String? monthlyProfit;
  final String? separateBusinessHouseholdMoney;
  final String? saveReinvestForGrowth;
  final String? accessToCreditLoans;
  final String? productAvailabilityKnowledge;
  final String? stockCheckFrequency;
  final String? runOutOfProducts;
  final String? checkExpiryDates;
  final String? purchaseSuppliesInBulk;
  final String? trackProductSales;
  final String? maintainCustomerList;
  final String? rememberCustomerPreferences;
  final String? informCustomersAboutOffers;
  final String? askForFeedback;
  final String? giveDiscountsToRepeatCustomers;
  final String? handleCustomerComplaints;
  final bool onboardingCompleted;
  final List<String> favouriteCustomerIds;
  final bool financialTransactionsEnabled;
  final bool isAdmin;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.name,
    this.profilePicUrl,
    this.deviceToken,
    required this.createdAt,
    required this.lastLoginAt,
    this.language,
    this.education,
    this.ageRange,
    this.businessDomain,
    this.respondentName,
    this.age,
    this.educationLevel,
    this.yearsRunningBusiness,
    this.numEmployees,
    this.ownershipType,
    this.digitalPayments,
    this.socialMediaPromotion,
    this.recordIncomeExpenses,
    this.financialRecordsMethod,
    this.monthlyProfit,
    this.separateBusinessHouseholdMoney,
    this.saveReinvestForGrowth,
    this.accessToCreditLoans,
    this.productAvailabilityKnowledge,
    this.stockCheckFrequency,
    this.runOutOfProducts,
    this.checkExpiryDates,
    this.purchaseSuppliesInBulk,
    this.trackProductSales,
    this.maintainCustomerList,
    this.rememberCustomerPreferences,
    this.informCustomersAboutOffers,
    this.askForFeedback,
    this.giveDiscountsToRepeatCustomers,
    this.handleCustomerComplaints,
    this.onboardingCompleted = false,
    this.favouriteCustomerIds = const [],
    this.financialTransactionsEnabled = true,
    this.isAdmin = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      phoneNumber: data['phoneNumber'] ?? '',
      name: data['name'],
      profilePicUrl: data['profilePicUrl'],
      deviceToken: data['deviceToken'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      language: data['language'],
      education: data['education'],
      ageRange: data['ageRange'],
      businessDomain: data['businessDomain'],
      respondentName: data['respondentName'],
      age: data['age'],
      educationLevel: data['educationLevel'],
      yearsRunningBusiness: data['yearsRunningBusiness'],
      numEmployees: data['numEmployees'],
      ownershipType: data['ownershipType'],
      digitalPayments: data['digitalPayments'],
      socialMediaPromotion: data['socialMediaPromotion'],
      recordIncomeExpenses: data['recordIncomeExpenses'],
      financialRecordsMethod: data['financialRecordsMethod'],
      monthlyProfit: data['monthlyProfit'],
      separateBusinessHouseholdMoney: data['separateBusinessHouseholdMoney'],
      saveReinvestForGrowth: data['saveReinvestForGrowth'],
      accessToCreditLoans: data['accessToCreditLoans'],
      productAvailabilityKnowledge: data['productAvailabilityKnowledge'],
      stockCheckFrequency: data['stockCheckFrequency'],
      runOutOfProducts: data['runOutOfProducts'],
      checkExpiryDates: data['checkExpiryDates'],
      purchaseSuppliesInBulk: data['purchaseSuppliesInBulk'],
      trackProductSales: data['trackProductSales'],
      maintainCustomerList: data['maintainCustomerList'],
      rememberCustomerPreferences: data['rememberCustomerPreferences'],
      informCustomersAboutOffers: data['informCustomersAboutOffers'],
      askForFeedback: data['askForFeedback'],
      giveDiscountsToRepeatCustomers: data['giveDiscountsToRepeatCustomers'],
      handleCustomerComplaints: data['handleCustomerComplaints'],
      onboardingCompleted: data['onboardingCompleted'] ?? false,
      favouriteCustomerIds:
          List<String>.from(data['favouriteCustomerIds'] ?? []),
      financialTransactionsEnabled:
          data['financialTransactionsEnabled'] ?? true,
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  /// Factory for creating UserModel from a plain Map (used with Supabase)
  /// Supports both camelCase and snake_case keys
  factory UserModel.fromMap(Map<String, dynamic> data) {
    // Helper to parse DateTime from various formats
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return UserModel(
      uid: data['uid'] ?? '',
      phoneNumber: data['phoneNumber'] ?? data['phone_number'] ?? '',
      name: data['name'],
      profilePicUrl: data['profilePicUrl'] ?? data['profile_pic_url'],
      deviceToken: data['deviceToken'] ?? data['device_token'],
      createdAt: parseDateTime(data['createdAt'] ?? data['created_at']),
      lastLoginAt: parseDateTime(data['lastLoginAt'] ?? data['last_login_at']),
      language: data['language'],
      education: data['education'],
      ageRange: data['ageRange'] ?? data['age_range'],
      businessDomain: data['businessDomain'] ?? data['business_domain'],
      respondentName: data['respondentName'] ?? data['respondent_name'],
      age: data['age'],
      educationLevel: data['educationLevel'] ?? data['education_level'],
      yearsRunningBusiness:
          data['yearsRunningBusiness'] ?? data['years_running_business'],
      numEmployees: data['numEmployees'] ?? data['num_employees'],
      ownershipType: data['ownershipType'] ?? data['ownership_type'],
      digitalPayments: data['digitalPayments'] ?? data['digital_payments'],
      socialMediaPromotion:
          data['socialMediaPromotion'] ?? data['social_media_promotion'],
      recordIncomeExpenses:
          data['recordIncomeExpenses'] ?? data['record_income_expenses'],
      financialRecordsMethod:
          data['financialRecordsMethod'] ?? data['financial_records_method'],
      monthlyProfit: data['monthlyProfit'] ?? data['monthly_profit'],
      separateBusinessHouseholdMoney: data['separateBusinessHouseholdMoney'] ??
          data['separate_business_household_money'],
      saveReinvestForGrowth:
          data['saveReinvestForGrowth'] ?? data['save_reinvest_for_growth'],
      accessToCreditLoans:
          data['accessToCreditLoans'] ?? data['access_to_credit_loans'],
      productAvailabilityKnowledge: data['productAvailabilityKnowledge'] ??
          data['product_availability_knowledge'],
      stockCheckFrequency:
          data['stockCheckFrequency'] ?? data['stock_check_frequency'],
      runOutOfProducts: data['runOutOfProducts'] ?? data['run_out_of_products'],
      checkExpiryDates: data['checkExpiryDates'] ?? data['check_expiry_dates'],
      purchaseSuppliesInBulk:
          data['purchaseSuppliesInBulk'] ?? data['purchase_supplies_in_bulk'],
      trackProductSales:
          data['trackProductSales'] ?? data['track_product_sales'],
      maintainCustomerList:
          data['maintainCustomerList'] ?? data['maintain_customer_list'],
      rememberCustomerPreferences: data['rememberCustomerPreferences'] ??
          data['remember_customer_preferences'],
      informCustomersAboutOffers: data['informCustomersAboutOffers'] ??
          data['inform_customers_about_offers'],
      askForFeedback: data['askForFeedback'] ?? data['ask_for_feedback'],
      giveDiscountsToRepeatCustomers: data['giveDiscountsToRepeatCustomers'] ??
          data['give_discounts_to_repeat_customers'],
      handleCustomerComplaints: data['handleCustomerComplaints'] ??
          data['handle_customer_complaints'],
      onboardingCompleted:
          data['onboardingCompleted'] ?? data['onboarding_completed'] ?? false,
      favouriteCustomerIds: List<String>.from(
          data['favouriteCustomerIds'] ?? data['favourite_customer_ids'] ?? []),
      financialTransactionsEnabled: data['financialTransactionsEnabled'] ??
          data['financial_transactions_enabled'] ??
          true,
      isAdmin: data['isAdmin'] ?? data['is_admin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'name': name,
      'profilePicUrl': profilePicUrl,
      'deviceToken': deviceToken,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'language': language,
      'education': education,
      'ageRange': ageRange,
      'businessDomain': businessDomain,
      'respondentName': respondentName,
      'age': age,
      'educationLevel': educationLevel,
      'yearsRunningBusiness': yearsRunningBusiness,
      'numEmployees': numEmployees,
      'ownershipType': ownershipType,
      'digitalPayments': digitalPayments,
      'socialMediaPromotion': socialMediaPromotion,
      'recordIncomeExpenses': recordIncomeExpenses,
      'financialRecordsMethod': financialRecordsMethod,
      'monthlyProfit': monthlyProfit,
      'separateBusinessHouseholdMoney': separateBusinessHouseholdMoney,
      'saveReinvestForGrowth': saveReinvestForGrowth,
      'accessToCreditLoans': accessToCreditLoans,
      'productAvailabilityKnowledge': productAvailabilityKnowledge,
      'stockCheckFrequency': stockCheckFrequency,
      'runOutOfProducts': runOutOfProducts,
      'checkExpiryDates': checkExpiryDates,
      'purchaseSuppliesInBulk': purchaseSuppliesInBulk,
      'trackProductSales': trackProductSales,
      'maintainCustomerList': maintainCustomerList,
      'rememberCustomerPreferences': rememberCustomerPreferences,
      'informCustomersAboutOffers': informCustomersAboutOffers,
      'askForFeedback': askForFeedback,
      'giveDiscountsToRepeatCustomers': giveDiscountsToRepeatCustomers,
      'handleCustomerComplaints': handleCustomerComplaints,
      'onboardingCompleted': onboardingCompleted,
      'favouriteCustomerIds': favouriteCustomerIds,
      'financialTransactionsEnabled': financialTransactionsEnabled,
      'isAdmin': isAdmin,
    };
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? name,
    String? profilePicUrl,
    String? deviceToken,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? language,
    String? education,
    String? ageRange,
    String? businessDomain,
    String? respondentName,
    String? age,
    String? educationLevel,
    String? yearsRunningBusiness,
    String? numEmployees,
    String? ownershipType,
    String? digitalPayments,
    String? socialMediaPromotion,
    String? recordIncomeExpenses,
    String? financialRecordsMethod,
    String? monthlyProfit,
    String? separateBusinessHouseholdMoney,
    String? saveReinvestForGrowth,
    String? accessToCreditLoans,
    String? productAvailabilityKnowledge,
    String? stockCheckFrequency,
    String? runOutOfProducts,
    String? checkExpiryDates,
    String? purchaseSuppliesInBulk,
    String? trackProductSales,
    String? maintainCustomerList,
    String? rememberCustomerPreferences,
    String? informCustomersAboutOffers,
    String? askForFeedback,
    String? giveDiscountsToRepeatCustomers,
    String? handleCustomerComplaints,
    bool? onboardingCompleted,
    List<String>? favouriteCustomerIds,
    bool? financialTransactionsEnabled,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      deviceToken: deviceToken ?? this.deviceToken,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      language: language ?? this.language,
      education: education ?? this.education,
      ageRange: ageRange ?? this.ageRange,
      businessDomain: businessDomain ?? this.businessDomain,
      respondentName: respondentName ?? this.respondentName,
      age: age ?? this.age,
      educationLevel: educationLevel ?? this.educationLevel,
      yearsRunningBusiness: yearsRunningBusiness ?? this.yearsRunningBusiness,
      numEmployees: numEmployees ?? this.numEmployees,
      ownershipType: ownershipType ?? this.ownershipType,
      digitalPayments: digitalPayments ?? this.digitalPayments,
      socialMediaPromotion: socialMediaPromotion ?? this.socialMediaPromotion,
      recordIncomeExpenses: recordIncomeExpenses ?? this.recordIncomeExpenses,
      financialRecordsMethod:
          financialRecordsMethod ?? this.financialRecordsMethod,
      monthlyProfit: monthlyProfit ?? this.monthlyProfit,
      separateBusinessHouseholdMoney:
          separateBusinessHouseholdMoney ?? this.separateBusinessHouseholdMoney,
      saveReinvestForGrowth:
          saveReinvestForGrowth ?? this.saveReinvestForGrowth,
      accessToCreditLoans: accessToCreditLoans ?? this.accessToCreditLoans,
      productAvailabilityKnowledge:
          productAvailabilityKnowledge ?? this.productAvailabilityKnowledge,
      stockCheckFrequency: stockCheckFrequency ?? this.stockCheckFrequency,
      runOutOfProducts: runOutOfProducts ?? this.runOutOfProducts,
      checkExpiryDates: checkExpiryDates ?? this.checkExpiryDates,
      purchaseSuppliesInBulk:
          purchaseSuppliesInBulk ?? this.purchaseSuppliesInBulk,
      trackProductSales: trackProductSales ?? this.trackProductSales,
      maintainCustomerList: maintainCustomerList ?? this.maintainCustomerList,
      rememberCustomerPreferences:
          rememberCustomerPreferences ?? this.rememberCustomerPreferences,
      informCustomersAboutOffers:
          informCustomersAboutOffers ?? this.informCustomersAboutOffers,
      askForFeedback: askForFeedback ?? this.askForFeedback,
      giveDiscountsToRepeatCustomers:
          giveDiscountsToRepeatCustomers ?? this.giveDiscountsToRepeatCustomers,
      handleCustomerComplaints:
          handleCustomerComplaints ?? this.handleCustomerComplaints,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      favouriteCustomerIds: favouriteCustomerIds ?? this.favouriteCustomerIds,
      financialTransactionsEnabled:
          financialTransactionsEnabled ?? this.financialTransactionsEnabled,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
