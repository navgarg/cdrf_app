import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class ResourceService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ResourceService({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Uploads [file] to storage and writes metadata to `resource_center` collection.
  Future<void> uploadResource({
    required File file,
    required String uploadedBy,
    String? fileName,
  }) async {
    final name = fileName ?? file.path.split(Platform.pathSeparator).last;
    final timestamp = DateTime.now().toUtc();
    final storagePath =
        'resource_center/$uploadedBy/${timestamp.millisecondsSinceEpoch}_$name';

    final ref = _storage.ref().child(storagePath);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final url = await snapshot.ref.getDownloadURL();

    await _firestore.collection('resource_center').add({
      'name': name,
      'url': url,
      'uploadedBy': uploadedBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'size': await file.length(),
    });
  }

  /// Stream resources ordered by timestamp desc
  Stream<QuerySnapshot<Map<String, dynamic>>> resourcesStream() {
    return _firestore
        .collection('resource_center')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
