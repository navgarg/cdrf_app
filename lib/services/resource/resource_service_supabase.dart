import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../../models/resource_entry.dart';
import '../interfaces/i_resource_service.dart';

/// Supabase implementation of resource/storage service
class ResourceServiceSupabase implements IResourceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<void> uploadResource({
    required File file,
    required String uploadedBy,
    String? fileName,
  }) async {
    final name = fileName ?? file.path.split(Platform.pathSeparator).last;
    final timestamp = DateTime.now().toUtc();
    final storagePath =
        'resource_center/$uploadedBy/${timestamp.millisecondsSinceEpoch}_$name';

    try {
      // Upload file to Supabase Storage
      final bytes = await file.readAsBytes();
      await _supabase.storage.from(SupabaseConfig.resourcesBucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: false,
            ),
          );

      // Get public URL
      final url = _supabase.storage
          .from(SupabaseConfig.resourcesBucket)
          .getPublicUrl(storagePath);

      // Save metadata to database
      await _supabase.from('resource_center').insert({
        'name': name,
        'url': url,
        'uploaded_by': uploadedBy,
        'timestamp': timestamp.toIso8601String(),
        'size': await file.length(),
      });
    } catch (e) {
      throw Exception('Failed to upload resource: $e');
    }
  }

  @override
  Stream<List<ResourceEntry>> resourcesStream() {
    return _supabase
        .from('resource_center')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false)
        .map((data) => data.map((row) {
              return ResourceEntry.fromMap(row);
            }).toList(growable: false));
  }
}
