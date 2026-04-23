import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/backend_config.dart';
import '../models/service_item.dart';
import '../services/adapters/firebase_services_service_adapter.dart';
import '../services/api/services_service_supabase.dart';
import '../services/interfaces/i_services_service.dart';

final servicesServiceSwitchProvider = Provider<IServicesService>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend == BackendType.firebase) {
    return FirebaseServicesServiceAdapter(ref);
  }
  return ServicesServiceSupabase(ref);
});

final servicesServiceProvider = Provider<IServicesService>((ref) {
  return ref.watch(servicesServiceSwitchProvider);
});

final serviceItemsProvider = StreamProvider<List<ServiceItem>>((ref) {
  return ref.watch(servicesServiceProvider).streamServiceItems();
});
