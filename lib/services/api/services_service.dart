import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/models/service_item.dart';
import 'package:nariudyam/models/business_domain.dart';
import 'package:nariudyam/services/api/auth_service.dart';
import 'package:nariudyam/services/general/messenger.dart';

final servicesServiceProvider = Provider((ref) => ServicesService(ref));

final serviceItemsProvider =
    StreamProvider.autoDispose<List<ServiceItem>>((ref) {
  final service = ref.watch(servicesServiceProvider);
  return service.streamServiceItems();
});

class ServicesService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _migrationAttempted = false;
  bool _cleanupAttempted = false;
  static bool _debugPrinted = false;

  ServicesService(this._ref);

  bool _isServiceBusiness() {
    final user = _ref.read(userProvider);
    return BusinessDomainUtils.isServiceDomain(user?.businessDomain);
  }

  // Canonical services collection (new name standardized back to 'services').
  CollectionReference<ServiceItem> _getCanonicalServicesCollection() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc(user.uid)
        .collection('services')
        .withConverter<ServiceItem>(
          fromFirestore: (snap, _) =>
              ServiceItem.fromMap(snap.data() ?? {}, snap.id),
          toFirestore: (item, _) => item.toMap(),
        );
  }

  // Legacy temporary location where we previously stored services ('products').
  CollectionReference<ServiceItem> _getLegacyProductsServicesCollection() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc(user.uid)
        .collection('products')
        .withConverter<ServiceItem>(
          fromFirestore: (snap, _) =>
              ServiceItem.fromMap(snap.data() ?? {}, snap.id),
          toFirestore: (item, _) => item.toMap(),
        );
  }

  Future<void> _migrateLegacyServicesIfNeeded() async {
    if (!_isServiceBusiness() || _migrationAttempted) return;
    _migrationAttempted = true;
    final canonical = await _getCanonicalServicesCollection().get();
    if (canonical.docs.isNotEmpty) return; // already in new place

    // Try migrating from legacy 'products' location first.
    final legacyProducts = await _getLegacyProductsServicesCollection().get();
    if (legacyProducts.docs.isNotEmpty) {
      for (final doc in legacyProducts.docs) {
        await _getCanonicalServicesCollection().doc(doc.id).set(doc.data());
      }
      // After successful copy, delete old docs to let the legacy collection disappear.
      for (final doc in legacyProducts.docs) {
        try {
          await doc.reference.delete();
        } catch (_) {
          // ignore individual deletion failures; safe to proceed
        }
      }
      return;
    }
    // If nothing in legacy products, there might still be very old 'services' (already canonical) -> nothing to do.
  }

  Future<void> _cleanupLegacyProductsCollectionIfNeeded() async {
    if (!_isServiceBusiness() || _cleanupAttempted) return;
    _cleanupAttempted = true;
    // Only attempt cleanup if canonical has data (otherwise migration step will handle later).
    final canonical = await _getCanonicalServicesCollection().get();
    if (canonical.docs.isEmpty) return;
    final legacyProducts = await _getLegacyProductsServicesCollection().get();
    if (legacyProducts.docs.isEmpty) return; // nothing to clean
    for (final doc in legacyProducts.docs) {
      try {
        await doc.reference.delete();
      } catch (_) {
        // ignore
      }
    }
  }

  Stream<List<ServiceItem>> streamServiceItems() async* {
    if (!_isServiceBusiness()) {
      // Non service business never uses services
      yield <ServiceItem>[];
      return;
    }
    if (!_debugPrinted) {
      _debugPrinted = true;
      final user = _ref.read(userProvider);
      // ignore: avoid_print
      print('[ServicesService] serviceBusiness domain=${user?.businessDomain}');
    }
    await _migrateLegacyServicesIfNeeded();
    await _cleanupLegacyProductsCollectionIfNeeded();
    yield* _getCanonicalServicesCollection()
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Future<bool> addServiceItem({
    required String name,
    String? description,
    required double price,
    required int duration,
  }) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        _ref.read(messengerProvider).showError('User not logged in.');
        return false;
      }
      if (!_isServiceBusiness()) {
        throw Exception('addServiceItem called for non-service business');
      }
      final newService = ServiceItem(
        id: '',
        name: name,
        description: description,
        price: price,
        duration: duration,
      );
      await _getCanonicalServicesCollection().add(newService);
      // Fire a cleanup attempt (no-op if already cleaned) to ensure 'products' disappears quickly after additions.
      Future.microtask(_cleanupLegacyProductsCollectionIfNeeded);
      _ref.read(messengerProvider).showSuccess('Service added successfully!');
      return true;
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to add service: ${e.toString()}');
      return false;
    }
  }
}
