import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/favourite_customer.dart';
import '../api/fav_customer_service.dart' as firebase;
import '../api/transaction_service.dart' as firebase_tx;
import '../interfaces/i_favourite_customer_service.dart';

class FirebaseFavouriteCustomerServiceAdapter
    implements IFavouriteCustomerService {
  final firebase.FavouriteCustomerService _service;

  FirebaseFavouriteCustomerServiceAdapter(
    Ref ref, {
    required String? userId,
    required String? businessId,
  }) : _service = firebase.FavouriteCustomerService(
          ref,
          userId,
          businessId,
          firebase_tx.TransactionService(ref),
        );

  @override
  Stream<List<FavouriteCustomer>> streamFavouriteCustomers() =>
      _service.streamFavouriteCustomers();

  @override
  Future<List<FavouriteCustomer>> getFavouriteCustomers() =>
      _service.getFavouriteCustomers();

  @override
  Future<bool> addFavouriteCustomer(
    String name, {
    String? phoneNumber,
    double? creditOutstanding,
  }) {
    return _service.addFavouriteCustomer(
      name,
      phoneNumber: phoneNumber,
      creditOutstanding: creditOutstanding,
    );
  }

  @override
  Future<bool> updateFavouriteCustomer(
    String customerId, {
    String? name,
    String? phoneNumber,
    double? creditOutstanding,
    DateTime? lastPurchaseDate,
    double? avgMonthlySpend,
    String? loyaltyStatus,
  }) {
    return _service.updateFavouriteCustomer(
      customerId,
      name: name,
      phoneNumber: phoneNumber,
      creditOutstanding: creditOutstanding,
      lastPurchaseDate: lastPurchaseDate,
      avgMonthlySpend: avgMonthlySpend,
      loyaltyStatus: loyaltyStatus,
    );
  }

  @override
  Future<bool> deleteFavouriteCustomer(String customerId) =>
      _service.deleteFavouriteCustomer(customerId);
}
