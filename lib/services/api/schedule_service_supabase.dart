import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/appointment.dart';
import '../../models/business_domain.dart';
import '../../providers/shared_providers.dart';
import '../../services/general/messenger.dart';
import '../interfaces/i_schedule_service.dart';

class ScheduleServiceSupabase implements IScheduleService {
  final Ref _ref;
  final SupabaseClient _supabase = Supabase.instance.client;

  ScheduleServiceSupabase(this._ref);

  String _requireUserId() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    return user.uid;
  }

  @override
  Stream<List<Appointment>> streamAppointments(
      {required BusinessDomain forDomain}) {
    final user = _ref.read(userProvider);
    if (user == null) return Stream.value(<Appointment>[]);

    return _supabase
        .from('appointments')
        .stream(primaryKey: ['id']).map((rows) {
      final appointments = rows
          .where((row) =>
              row['user_id'] == user.uid &&
              row['business_domain'] == forDomain.stringValue)
          .map((row) => Appointment.fromMap(row, row['id'].toString()))
          .toList(growable: true);

      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return appointments;
    });
  }

  @override
  Future<bool> addAppointment({
    required String title,
    required DateTime date,
    required TimeOfDay time,
    required BusinessDomain businessDomain,
    String? customerId,
  }) async {
    try {
      final uid = _requireUserId();

      final fullDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      final appointment = Appointment(
        id: '',
        title: title,
        dateTime: fullDateTime,
        businessDomain: businessDomain,
        customerId: customerId,
      );

      await _supabase
          .from('appointments')
          .insert(appointment.toSupabaseMap(userId: uid));

      _ref
          .read(messengerProvider)
          .showSuccess('Appointment added successfully!');
      return true;
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to add appointment: ${e.toString()}');
      return false;
    }
  }
}
