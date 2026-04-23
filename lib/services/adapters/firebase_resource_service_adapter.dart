import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../../models/resource_entry.dart';
import '../interfaces/i_resource_service.dart';
import '../resource/resource_service.dart' as firebase;

/// Adapter that uses the existing Firebase `ResourceService` without modifying it.
class FirebaseResourceServiceAdapter implements IResourceService {
  final firebase.ResourceService _service;

  FirebaseResourceServiceAdapter() : _service = firebase.ResourceService();

  @override
  Future<void> uploadResource({
    required File file,
    required String uploadedBy,
    String? fileName,
  }) {
    return _service.uploadResource(
      file: file,
      uploadedBy: uploadedBy,
      fileName: fileName,
    );
  }

  @override
  Stream<List<ResourceEntry>> resourcesStream() {
    return _service
        .resourcesStream()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        final ts = data['timestamp'];
        final timestamp = ts is Timestamp ? ts.toDate() : DateTime.now();

        return ResourceEntry(
          id: doc.id,
          name: (data['name'] ?? 'file').toString(),
          url: (data['url'] ?? '').toString(),
          uploadedBy: (data['uploadedBy'] ?? '').toString(),
          timestamp: timestamp.toUtc(),
          size: (data['size'] ?? 0) is int
              ? (data['size'] as int)
              : int.tryParse((data['size'] ?? 0).toString()) ?? 0,
        );
      }).toList(growable: false);
    });
  }
}
