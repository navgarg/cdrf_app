import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_selector/file_selector.dart';

import '../../services/resource/resource_service.dart';
import '../../services/api/auth_service.dart';
import '../../services/general/messenger.dart';
import '../../components/generic_list_tile.dart';

class ResourceCenterScreen extends ConsumerStatefulWidget {
  const ResourceCenterScreen({super.key});

  @override
  ConsumerState<ResourceCenterScreen> createState() =>
      _ResourceCenterScreenState();
}

class _ResourceCenterScreenState extends ConsumerState<ResourceCenterScreen> {
  final _service = ResourceService();

  Future<void> _pickAndUpload() async {
    // Use file_selector which provides platform file picking across mobile/desktop
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'files',
      // allow common mime types; empty means all
      extensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    final XFile? picked = await openFile(acceptedTypeGroups: [typeGroup]);
    if (picked == null) return;

    // On web, XFile may not expose a path; use bytes if necessary
    if (kIsWeb) {
      ref.read(messengerProvider).showError('Upload not supported on web yet');
      return;
    }

    final file = File(picked.path);
    final user = ref.read(userProvider);
    if (user == null) return;
    try {
      await _service.uploadResource(
          file: file, uploadedBy: user.uid, fileName: picked.name);
      ref.read(messengerProvider).showSuccess('Uploaded ${picked.name}');
    } catch (e) {
      ref.read(messengerProvider).showError('Upload failed: ${e.toString()}');
    }
  }

  // Group files by date (date only, no time)
  Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> _groupByDate(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
        grouped = {};

    for (final doc in docs) {
      final data = doc.data();
      final ts = data['timestamp'] as Timestamp?;
      final date = ts != null ? ts.toDate() : DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(date.toLocal());

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(doc);
    }

    return grouped;
  }

  Widget _buildList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.resourcesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No resources uploaded yet'));
        }

        // Group by date
        final grouped = _groupByDate(docs);
        final sortedDates = grouped.keys.toList()
          ..sort((a, b) => b.compareTo(a)); // Latest first

        return ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final dateKey = sortedDates[index];
            final filesForDate = grouped[dateKey]!;
            final date = DateTime.parse(dateKey);
            final dateHeading = DateFormat('EEEE, MMMM d, y').format(date);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date heading
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.3),
                  child: Text(
                    dateHeading,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // Files for this date
                ...filesForDate.map((doc) {
                  final data = doc.data();
                  final name = data['name'] as String? ?? 'file';
                  final url = data['url'] as String? ?? '';
                  final ts = data['timestamp'] as Timestamp?;
                  final fileDate = ts != null ? ts.toDate() : DateTime.now();
                  final timeFormatted =
                      DateFormat.jm().format(fileDate.toLocal());

                  return ListTile(
                    leading: Icon(
                      name.endsWith('.pdf')
                          ? Icons.picture_as_pdf
                          : Icons.image,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(name),
                    subtitle: Text(timeFormatted),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: url.isNotEmpty
                          ? () async {
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            }
                          : null,
                    ),
                    onTap: url.isNotEmpty
                        ? () async {
                            final uri = Uri.parse(url);
                            if (await canLaunchUrl(uri)) await launchUrl(uri);
                          }
                        : null,
                  );
                }),
                const Divider(height: 1, thickness: 2),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Upload tile at the top
          GenericListTile(
            leading: Icon(Icons.upload_file,
                color: theme.colorScheme.primary, size: 28),
            titleWidget: const Text(
              'Upload Resource (PDF/Image)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: Icon(Icons.add_circle,
                size: 28, color: theme.colorScheme.primary),
            onTap: _pickAndUpload,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 2),
          const SizedBox(height: 8),
          // File list grouped by date
          Expanded(
            child: _buildList(),
          ),
        ],
      ),
    );
  }
}
