// firebase (previous implementation)
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_selector/file_selector.dart';

// firebase (previous implementation)
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../services/resource/resource_service.dart';

import '../../models/resource_entry.dart';
import '../../providers/auth_providers.dart';
import '../../providers/resource_providers.dart';
import '../../services/general/messenger.dart';
import '../../components/generic_list_tile.dart';
import '../../l10n/dynamic_localizations.dart';

class ResourceCenterScreen extends ConsumerStatefulWidget {
  const ResourceCenterScreen({super.key});

  @override
  ConsumerState<ResourceCenterScreen> createState() =>
      _ResourceCenterScreenState();
}

class _ResourceCenterScreenState extends ConsumerState<ResourceCenterScreen> {
  // firebase (previous implementation)
  /*
  final _service = ResourceService();
  */

  Future<void> _pickAndUpload() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'files',
      extensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    final XFile? picked = await openFile(acceptedTypeGroups: [typeGroup]);
    if (picked == null) return;
    final pickedName = picked.name;

    if (!mounted) return;

    if (kIsWeb) {
      ref
          .read(messengerProvider)
          .showError(context.tr('Upload not supported on web yet'));
      return;
    }

    final file = File(picked.path);
    final user = ref.read(userProvider);
    if (user == null) return;
    try {
      await ref.read(resourceServiceProvider).uploadResource(
          file: file, uploadedBy: user.uid, fileName: pickedName);
      if (!mounted) return;
      ref
          .read(messengerProvider)
          .showSuccess(context.tr('Uploaded $pickedName'));
    } catch (e) {
      if (!mounted) return;
      ref.read(messengerProvider).showError(context.tr('Upload failed: $e'));
    }
  }

  // Group files by date (date only, no time)
  Map<String, List<ResourceEntry>> _groupByDate(List<ResourceEntry> entries) {
    final Map<String, List<ResourceEntry>> grouped = {};

    for (final entry in entries) {
      final dateKey =
          DateFormat('yyyy-MM-dd').format(entry.timestamp.toLocal());
      (grouped[dateKey] ??= []).add(entry);
    }

    return grouped;
  }

  Widget _buildList() {
    // firebase (previous implementation)
    /*
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.resourcesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(child: Text(context.tr('No resources uploaded yet')));
        }

        // Group by date
        final grouped = _groupByDate(docs);
        final sortedDates = grouped.keys.toList()
          ..sort((a, b) => b.compareTo(a)); // Latest first

        // ... same UI, mapping docs -> name/url/timestamp
      },
    );
    */

    return StreamBuilder<List<ResourceEntry>>(
      stream: ref.watch(resourceServiceProvider).resourcesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = snapshot.data ?? const <ResourceEntry>[];
        if (entries.isEmpty) {
          return Center(child: Text(context.tr('No resources uploaded yet')));
        }

        // Group by date
        final grouped = _groupByDate(entries);
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
                      .withAlpha((0.3 * 255).round()),
                  child: Text(
                    dateHeading,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // Files for this date
                ...filesForDate.map((entry) {
                  final name = entry.name;
                  final url = entry.url;
                  final timeFormatted =
                      DateFormat.jm().format(entry.timestamp.toLocal());

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
            titleWidget: Text(
              context.tr('Upload Resource (PDF/Image)'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

