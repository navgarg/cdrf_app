import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/appointment.dart';
import '../../models/business_domain.dart';
import '../api/schedule_service.dart' as firebase;
import '../interfaces/i_schedule_service.dart';

class FirebaseScheduleServiceAdapter implements IScheduleService {
  final firebase.ScheduleService _service;

  FirebaseScheduleServiceAdapter(Ref ref)
      : _service = firebase.ScheduleService(ref);

  @override
  Stream<List<Appointment>> streamAppointments(
      {required BusinessDomain forDomain}) {
    return _service.streamAppointments(forDomain: forDomain);
  }

  @override
  Future<bool> addAppointment({
    required String title,
    required DateTime date,
    required TimeOfDay time,
    required BusinessDomain businessDomain,
    String? customerId,
  }) {
    return _service.addAppointment(
      title: title,
      date: date,
      time: time,
      businessDomain: businessDomain,
      customerId: customerId,
    );
  }
}
