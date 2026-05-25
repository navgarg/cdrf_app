import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/service_item.dart';
import '../../models/business_domain.dart';
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
    return BusinessDomainUtils.isServiceDomain(user?.businessDomain);
  }

  @override
  Stream<List<ServiceItem>> streamServiceItems() async* {
    if (!_isServiceBusiness()) {
      yield <ServiceItem>[];
      return;
    }

    final user = _ref.read(userProvider);
    if (user == null) {
      yield <ServiceItem>[];
      return;
    }
    final uid = user.uid;

    yield await _fetchServiceItems(uid);

    try {
      await for (final rows in _supabase
          .from('services')
          .stream(primaryKey: ['id'])
          .eq('user_id', uid)
          .order('name', ascending: true)) {
        yield _mapServiceRows(rows);
      }
    } catch (e) {
      debugPrint('streamServiceItems realtime failed: $e');
    }
  }

  Future<List<ServiceItem>> _fetchServiceItems(String uid) async {
    final rows = await _supabase
        .from('services')
        .select()
        .eq('user_id', uid)
        .order('name', ascending: true);
    return _mapServiceRows(rows);
  }

  List<ServiceItem> _mapServiceRows(List<Map<String, dynamic>> rows) {
    return rows
        .map((row) => ServiceItem.fromMap(row, row['id'].toString()))
        .toList(growable: false);
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
