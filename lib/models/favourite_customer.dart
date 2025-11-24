import 'package:cloud_firestore/cloud_firestore.dart';

class FavouriteCustomer {
  final String id;
  final String name;
  final String? phoneNumber;
  final double? creditOutstanding;
  final DateTime? lastPurchaseDate;
  final double? avgMonthlySpend;
  final String? loyaltyStatus;

  FavouriteCustomer({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.creditOutstanding,
    this.lastPurchaseDate,
    this.avgMonthlySpend,
    this.loyaltyStatus,
  });

  factory FavouriteCustomer.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return FavouriteCustomer(
      id: snapshot.id,
      name: data?['name'] ?? '',
      phoneNumber: data?['phone_number'],
      creditOutstanding: (data?['credit_outstanding'] as num?)?.toDouble(),
      lastPurchaseDate: (data?['last_purchase_date'] as Timestamp?)?.toDate(),
      avgMonthlySpend: (data?['avg_monthly_spend'] as num?)?.toDouble(),
      loyaltyStatus: data?['loyalty_status'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone_number': phoneNumber,
      'credit_outstanding': creditOutstanding,
      'last_purchase_date': lastPurchaseDate != null ? Timestamp.fromDate(lastPurchaseDate!) : null,
      'avg_monthly_spend': avgMonthlySpend,
      'loyalty_status': loyaltyStatus,
    };
  }

  FavouriteCustomer copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    double? creditOutstanding,
    DateTime? lastPurchaseDate,
    double? avgMonthlySpend,
    String? loyaltyStatus,
  }) {
    return FavouriteCustomer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      creditOutstanding: creditOutstanding ?? this.creditOutstanding,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      avgMonthlySpend: avgMonthlySpend ?? this.avgMonthlySpend,
      loyaltyStatus: loyaltyStatus ?? this.loyaltyStatus,
    );
  }
}