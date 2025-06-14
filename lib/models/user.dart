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
  final bool onboardingCompleted;

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
    this.onboardingCompleted = false
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
      onboardingCompleted: data['onboardingCompleted'] ?? false
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
      'onboardingCompleted': onboardingCompleted,
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
    bool? onboardingCompleted,
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
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
