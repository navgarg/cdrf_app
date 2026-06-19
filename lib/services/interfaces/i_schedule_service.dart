import 'package:flutter/material.dart';

import '../../models/appointment.dart';
import '../../models/business_domain.dart';

abstract class IScheduleService {
  Stream<List<Appointment>> streamAppointments(
      {required BusinessDomain forDomain});

  Future<bool> addAppointment({
    required String title,
    required DateTime date,
    required TimeOfDay time,
    required BusinessDomain businessDomain,
    String? customerId,
  });
}
