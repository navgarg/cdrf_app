import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/backend_config.dart';
import '../models/appointment.dart';
import '../models/business_domain.dart';
import '../providers/shared_providers.dart';
import '../services/adapters/firebase_schedule_service_adapter.dart';
import '../services/api/schedule_service_supabase.dart';
import '../services/interfaces/i_schedule_service.dart';

final scheduleServiceSwitchProvider = Provider<IScheduleService>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend == BackendType.firebase) {
    return FirebaseScheduleServiceAdapter(ref);
  }
  return ScheduleServiceSupabase(ref);
});

/// Compatibility provider name.
final scheduleServiceProvider = Provider<IScheduleService>((ref) {
  return ref.watch(scheduleServiceSwitchProvider);
});

/// Current business domain, auto-initialized from user profile.
final currentDomainProvider = StateProvider<BusinessDomain?>((ref) {
  final user = ref.watch(userProvider);
  if (user?.businessDomain != null) {
    return BusinessDomainExtension.fromString(user!.businessDomain!);
  }
  return null;
});

final appointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  final currentDomain = ref.watch(currentDomainProvider);
  if (currentDomain == null) return Stream.value(<Appointment>[]);
  return ref
      .watch(scheduleServiceProvider)
      .streamAppointments(forDomain: currentDomain);
});
