import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/backend_config.dart';
import '../models/business_domain.dart';
import '../models/favourite_customer.dart';
import '../providers/shared_providers.dart';
import '../services/adapters/firebase_fav_customer_service_adapter.dart';
import '../services/api/fav_customer_service_supabase.dart';
import '../services/interfaces/i_favourite_customer_service.dart';
import 'transaction_providers.dart';
import 'schedule_providers.dart';

/// Mirror the existing FutureProvider used by week_view.dart.
final favCustomerServiceProvider =
    FutureProvider<List<FavouriteCustomer>>((ref) async {
  final user = ref.watch(userProvider);
  final currentDomain = ref.watch(currentDomainProvider);
  if (user == null || currentDomain == null) {
    return <FavouriteCustomer>[];
  }
  // Domain currently not used for filtering; keep behavior consistent with previous code.
  final service = ref.watch(favouriteCustomerServiceProvider(user.uid));
  return service.getFavouriteCustomers();
});

final favouriteCustomerServiceSwitchProvider =
    Provider.family<IFavouriteCustomerService, String?>((ref, userId) {
  final backend = ref.watch(backendProvider);
  final currentDomain = ref.watch(currentDomainProvider);

  if (backend == BackendType.firebase) {
    return FirebaseFavouriteCustomerServiceAdapter(
      ref,
      userId: userId,
      businessId: currentDomain?.stringValue,
    );
  }

  return FavouriteCustomerServiceSupabase(
    ref,
    ref.watch(transactionServiceProvider),
  );
});

/// Compatibility provider name used by multiple screens.
final favouriteCustomerServiceProvider =
    Provider.family<IFavouriteCustomerService, String?>((ref, userId) {
  return ref.watch(favouriteCustomerServiceSwitchProvider(userId));
});

final favouriteCustomersProvider =
    StreamProvider.family<List<FavouriteCustomer>, String?>((ref, userId) {
  return ref
      .watch(favouriteCustomerServiceProvider(userId))
      .streamFavouriteCustomers();
});
