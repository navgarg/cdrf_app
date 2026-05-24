import 'package:cloud_firestore/cloud_firestore.dart';

import 'business_domain.dart';

class Appointment {
  final String id;
  final String title;
  final DateTime dateTime;
  final BusinessDomain businessDomain;
  final String? customerId;

  Appointment({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.businessDomain,
    this.customerId,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      businessDomain:
          BusinessDomainExtension.fromString(data['businessDomain']),
      customerId: data['customerId'],
    );
  }

  factory Appointment.fromMap(Map<String, dynamic> data, String id) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    final rawDomain = data['businessDomain'] ?? data['business_domain'];
    return Appointment(
      id: id,
      title: data['title'] ?? 'Untitled',
      dateTime: parseDateTime(data['dateTime'] ?? data['date_time']),
      businessDomain: BusinessDomainExtension.fromString(rawDomain),
      customerId: data['customerId'] ?? data['customer_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateTime': Timestamp.fromDate(dateTime),
      'businessDomain': businessDomain.stringValue,
      'customerId': customerId,
    };
  }

  Map<String, dynamic> toSupabaseMap({required String userId}) {
    return {
      'user_id': userId,
      'title': title,
      'date_time': dateTime.toIso8601String(),
      'business_domain': businessDomain.stringValue,
      'customer_id': customerId,
    };
  }
}
