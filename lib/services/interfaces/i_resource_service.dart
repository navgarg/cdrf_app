import 'dart:io';

import '../../models/resource_entry.dart';

/// Abstract interface for resource/storage services
/// Both Firebase Storage and Supabase Storage implementations must follow this contract
abstract class IResourceService {
  /// Upload a file to storage and save metadata
  Future<void> uploadResource({
    required File file,
    required String uploadedBy,
    String? fileName,
  });

  /// Stream of resources ordered by timestamp descending
  Stream<List<ResourceEntry>> resourcesStream();
}
