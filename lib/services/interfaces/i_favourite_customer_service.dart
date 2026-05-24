import '../../models/favourite_customer.dart';

abstract class IFavouriteCustomerService {
  Stream<List<FavouriteCustomer>> streamFavouriteCustomers();

  Future<List<FavouriteCustomer>> getFavouriteCustomers();

  Future<bool> addFavouriteCustomer(
    String name, {
    String? phoneNumber,
    double? creditOutstanding,
  });

  Future<bool> updateFavouriteCustomer(
    String customerId, {
    String? name,
    String? phoneNumber,
    double? creditOutstanding,
    DateTime? lastPurchaseDate,
    double? avgMonthlySpend,
    String? loyaltyStatus,
  });

  Future<bool> deleteFavouriteCustomer(String customerId);
}
