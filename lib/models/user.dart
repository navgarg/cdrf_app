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
      favouriteCustomerIds: List<String>.from(data['favouriteCustomerIds'] ?? []),
      financialTransactionsEnabled: data['financialTransactionsEnabled'] ?? true,
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
      financialRecordsMethod: financialRecordsMethod ?? this.financialRecordsMethod,
      monthlyProfit: monthlyProfit ?? this.monthlyProfit,
      separateBusinessHouseholdMoney: separateBusinessHouseholdMoney ?? this.separateBusinessHouseholdMoney,
      saveReinvestForGrowth: saveReinvestForGrowth ?? this.saveReinvestForGrowth,
      accessToCreditLoans: accessToCreditLoans ?? this.accessToCreditLoans,
      productAvailabilityKnowledge: productAvailabilityKnowledge ?? this.productAvailabilityKnowledge,
      stockCheckFrequency: stockCheckFrequency ?? this.stockCheckFrequency,
      runOutOfProducts: runOutOfProducts ?? this.runOutOfProducts,
      checkExpiryDates: checkExpiryDates ?? this.checkExpiryDates,
      purchaseSuppliesInBulk: purchaseSuppliesInBulk ?? this.purchaseSuppliesInBulk,
      trackProductSales: trackProductSales ?? this.trackProductSales,
      maintainCustomerList: maintainCustomerList ?? this.maintainCustomerList,
      rememberCustomerPreferences: rememberCustomerPreferences ?? this.rememberCustomerPreferences,
      informCustomersAboutOffers: informCustomersAboutOffers ?? this.informCustomersAboutOffers,
      askForFeedback: askForFeedback ?? this.askForFeedback,
      giveDiscountsToRepeatCustomers: giveDiscountsToRepeatCustomers ?? this.giveDiscountsToRepeatCustomers,
      handleCustomerComplaints: handleCustomerComplaints ?? this.handleCustomerComplaints,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      favouriteCustomerIds: favouriteCustomerIds ?? this.favouriteCustomerIds,
      financialTransactionsEnabled: financialTransactionsEnabled ?? this.financialTransactionsEnabled,
    );
  }
}
