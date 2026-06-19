import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/config/supabase_config.dart';
import 'package:nariudyam/l10n/dynamic_localizations.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import 'package:nariudyam/services/general/messenger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoPickerField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String folder;

  const PhotoPickerField({
    super.key,
    required this.controller,
    required this.folder,
  });

  @override
  ConsumerState<PhotoPickerField> createState() => _PhotoPickerFieldState();
}

class _PhotoPickerFieldState extends ConsumerState<PhotoPickerField> {
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final userId = ref.read(userProvider)?.uid;
    if (userId == null) {
      ref.read(messengerProvider).showError(context.tr('User not logged in'));
      return;
    }
    final photoAddedMessage = context.tr('Photo added');
    final uploadFailedMessage = context.tr('Photo upload failed');

    const imageGroup = XTypeGroup(
      label: 'Images',
      extensions: ['jpg', 'jpeg', 'png', 'webp'],
      mimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
    );
    final file = await openFile(acceptedTypeGroups: [imageGroup]);
    if (file == null) return;

    setState(() => _isUploading = true);
    try {
      final bytes = await file.readAsBytes();
      final extension = file.name.split('.').last.toLowerCase();
      final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      final storagePath =
          'item_photos/${widget.folder}/$userId/${timestamp}_${file.name}';

      await Supabase.instance.client.storage
          .from(SupabaseConfig.resourcesBucket)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: _contentType(extension),
              upsert: false,
            ),
          );

      final url = Supabase.instance.client.storage
          .from(SupabaseConfig.resourcesBucket)
          .getPublicUrl(storagePath);
      widget.controller.text = url;
      ref.read(messengerProvider).showSuccess(photoAddedMessage);
      if (mounted) setState(() {});
    } catch (e) {
      ref.read(messengerProvider).showError(
            '$uploadFailedMessage: $e',
          );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String _contentType(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.controller.text.trim();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (imageUrl.isNotEmpty)
          Container(
            height: 120,
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image_not_supported_outlined,
                color: theme.colorScheme.primary,
                size: 42,
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: _isUploading ? null : _pickAndUpload,
          icon: _isUploading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_library_outlined),
          label: Text(
            context.tr(imageUrl.isEmpty ? 'Choose Photo' : 'Change Photo'),
          ),
        ),
      ],
    );
  }
}
