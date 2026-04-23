import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/service_item.dart';
import '../../providers/shared_providers.dart';
import '../../services/general/messenger.dart';
import '../interfaces/i_services_service.dart';

class ServicesServiceSupabase implements IServicesService {
  final Ref _ref;
  final SupabaseClient _supabase = Supabase.instance.client;

  ServicesServiceSupabase(this._ref);

  String _requireUserId() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    return user.uid;
  }

  bool _isServiceBusiness() {
    final user = _ref.read(userProvider);
    final raw = user?.businessDomain ?? '';
    return raw.trim().toLowerCase() == 'beauty parlor';
  }

  @override
  Stream<List<ServiceItem>> streamServiceItems() {
    if (!_isServiceBusiness()) {
      return Stream.value(<ServiceItem>[]);
    }

    final user = _ref.read(userProvider);
    if (user == null) return Stream.value(<ServiceItem>[]);

    return _supabase
        .from('services')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.uid)
        .order('name', ascending: true)
        .map((rows) {
          return rows
              .map((row) => ServiceItem.fromMap(row, row['id'].toString()))
              .toList(growable: false);
        });
  }

  @override
  Future<bool> addServiceItem({
    required String name,
    String? description,
    required double price,
    required int duration,
  }) async {
    try {
      final uid = _requireUserId();
      if (!_isServiceBusiness()) {
        throw Exception('addServiceItem called for non-service business');
      }

      await _supabase.from('services').insert({
        'user_id': uid,
        'business_id': uid,
        'name': name,
        'description': description,
        'price': price,
        'duration': duration,
      });

      _ref.read(messengerProvider).showSuccess('Service added successfully!');
      return true;
    } catch (e) {
      debugPrint('addServiceItem failed: $e');
      _ref
          .read(messengerProvider)
          .showError('Failed to add service: ${e.toString()}');
      return false;
    }
  }
}
