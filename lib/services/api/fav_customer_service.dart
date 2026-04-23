import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/favourite_customer.dart';
import '../general/messenger.dart';
import 'auth_service.dart';
import 'package:nariudyam/services/api/schedule_service.dart';
import 'package:nariudyam/services/api/transaction_service.dart';
import 'package:nariudyam/models/business_domain.dart';

final favCustomerServiceProvider =
    FutureProvider<List<FavouriteCustomer>>((ref) async {
  final user = ref.watch(userProvider);
  final currentDomain = ref.watch(currentDomainProvider);
  // Previous implementation:
  // if (user == null || user.uid == null || currentDomain == null) {
  if (user == null || currentDomain == null) {
    return [];
  }
  final favCustomerService = FavouriteCustomerService(ref, user.uid,
      currentDomain.stringValue, ref.watch(transactionServiceProvider));
  return await favCustomerService.getFavouriteCustomers();
});

class FavouriteCustomerService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId;
  final String? businessId;
  final TransactionService _transactionService;

  FavouriteCustomerService(
      this._ref, this.userId, this.businessId, this._transactionService);

  CollectionReference<FavouriteCustomer> _getCollection() {
    if (userId == null || businessId == null) {
      throw Exception('User not logged in or business not selected');
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('businesses')
        .doc(businessId)
        .collection('favouriteCustomers')
        .withConverter<FavouriteCustomer>(
          fromFirestore: (snapshot, options) =>
              FavouriteCustomer.fromFirestore(snapshot, options),
          toFirestore: (customer, _) => customer.toFirestore(),
        );
  }

  Stream<List<FavouriteCustomer>> streamFavouriteCustomers() {
    return _getCollection().snapshots().asyncMap((snapshot) async {
      final customers = snapshot.docs.map((doc) => doc.data()).toList();
      final customersWithMetrics = await Future.wait(
        customers.map((customer) => _calculateCustomerMetrics(customer)),
      );
      return customersWithMetrics;
    });
  }

  Future<List<FavouriteCustomer>> getFavouriteCustomers() async {
    final snapshot = await _getCollection().get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<bool> addFavouriteCustomer(String name,
      {String? phoneNumber, double? creditOutstanding}) async {
    if (name.isEmpty) return false;
    try {
      final newCustomer = FavouriteCustomer(
        id: '',
        name: name,
        phoneNumber: phoneNumber,
        creditOutstanding: creditOutstanding,
      );
      await _getCollection().add(newCustomer);
      _ref.read(messengerProvider).showSuccess('"$name" added to favourites.');
      return true;
    } catch (e) {
      _ref.read(messengerProvider).showError('Failed to add customer: $e');
      return false;
    }
  }

  Future<bool> updateFavouriteCustomer(
    String customerId, {
    String? name,
    String? phoneNumber,
    double? creditOutstanding,
    DateTime? lastPurchaseDate,
    double? avgMonthlySpend,
    String? loyaltyStatus,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (creditOutstanding != null)
        updates['credit_outstanding'] = creditOutstanding;
      if (lastPurchaseDate != null)
        updates['last_purchase_date'] = Timestamp.fromDate(lastPurchaseDate);
      if (avgMonthlySpend != null)
        updates['avg_monthly_spend'] = avgMonthlySpend;
      if (loyaltyStatus != null) updates['loyalty_status'] = loyaltyStatus;

      if (updates.isNotEmpty) {
        await _getCollection().doc(customerId).update(updates);
        _ref
            .read(messengerProvider)
            .showSuccess('Customer updated successfully.');
      }
      return true;
    } catch (e) {
      _ref.read(messengerProvider).showError('Failed to update customer: $e');
      return false;
    }
  }

  Future<bool> deleteFavouriteCustomer(String customerId) async {
    try {
      await _getCollection().doc(customerId).delete();
      _ref
          .read(messengerProvider)
          .showSuccess('Customer removed from favourites.');
      return true;
    } catch (e) {
      _ref.read(messengerProvider).showError('Failed to remove customer: $e');
      return false;
    }
  }

  Future<FavouriteCustomer> _calculateCustomerMetrics(
      FavouriteCustomer customer) async {
    if (userId == null || businessId == null) {
      return customer;
    }

    final transactions = await _transactionService
        .streamTransactionsByCustomerId(customer.id)
        .first;

    if (transactions.isEmpty) {
      return customer.copyWith(
        lastPurchaseDate: null,
        avgMonthlySpend: 0.0,
        loyaltyStatus: 'New',
      );
    }

    // Calculate lastPurchaseDate
    final lastPurchaseDate = transactions
        .map((t) => t.timestamp)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    // Calculate avgMonthlySpend
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
    final recentTransactions =
        transactions.where((t) => t.timestamp.isAfter(sixMonthsAgo)).toList();

    double totalSpend = 0.0;
    for (var t in recentTransactions) {
      totalSpend += (t.price * t.quantity);
    }
    final avgMonthlySpend = recentTransactions.isEmpty ? 0.0 : totalSpend / 6;

    // Determine loyaltyStatus (simple example, can be more complex)
    String loyaltyStatus;
    if (totalSpend > 1000) {
      loyaltyStatus = 'Gold';
    } else if (totalSpend > 500) {
      loyaltyStatus = 'Silver';
    } else {
      loyaltyStatus = 'Bronze';
    }

    return customer.copyWith(
      lastPurchaseDate: lastPurchaseDate,
      avgMonthlySpend: avgMonthlySpend,
      loyaltyStatus: loyaltyStatus,
    );
  }
}

final favouriteCustomerServiceProvider =
    Provider.family<FavouriteCustomerService, String?>((ref, userId) {
  final businessId = ref.watch(userBusinessIdProvider);
  final transactionService = ref.watch(transactionServiceProvider);
  return FavouriteCustomerService(ref, userId, businessId, transactionService);
});

final favouriteCustomersProvider =
    StreamProvider.family<List<FavouriteCustomer>, String?>((ref, userId) {
  final favouriteCustomerService =
      ref.watch(favouriteCustomerServiceProvider(userId));
  return favouriteCustomerService.streamFavouriteCustomers();
});
