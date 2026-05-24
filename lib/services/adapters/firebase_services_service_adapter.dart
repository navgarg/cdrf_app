import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/service_item.dart';
import '../api/services_service.dart' as firebase;
import '../interfaces/i_services_service.dart';

class FirebaseServicesServiceAdapter implements IServicesService {
  final firebase.ServicesService _service;

  FirebaseServicesServiceAdapter(Ref ref)
      : _service = firebase.ServicesService(ref);

  @override
  Stream<List<ServiceItem>> streamServiceItems() =>
      _service.streamServiceItems();

  @override
  Future<bool> addServiceItem({
    required String name,
    String? description,
    required double price,
    required int duration,
  }) {
    return _service.addServiceItem(
      name: name,
      description: description,
      price: price,
      duration: duration,
    );
  }
}
