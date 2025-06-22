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
      businessDomain: BusinessDomainExtension.fromString(data['businessDomain']),
      customerId: data['customerId'],
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
}