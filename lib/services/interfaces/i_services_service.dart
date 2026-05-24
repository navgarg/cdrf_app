import '../../models/service_item.dart';

abstract class IServicesService {
  Stream<List<ServiceItem>> streamServiceItems();

  Future<bool> addServiceItem({
    required String name,
    String? description,
    required double price,
    required int duration,
  });
}
