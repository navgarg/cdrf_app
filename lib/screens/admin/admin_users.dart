// firebase (previous implementation)
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nariudyam/providers/admin_providers.dart';
import '../../l10n/dynamic_localizations.dart';

// firebase (previous implementation)
// import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // firebase (previous implementation)
    /*
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(context.tr('Error: ${snapshot.error}')));
        }

        final users = snapshot.data?.docs ?? [];
        if (users.isEmpty) {
          return Center(child: Text(context.tr('No users found')));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final name = userData['name'] ?? context.tr('Unknown');
            final phone = userData['phoneNumber'] ?? context.tr('N/A');
            final businessDomain = userData['businessDomain'] ?? context.tr('N/A');
            final createdAt = userData['createdAt'] as Timestamp?;
            final dateStr = createdAt != null
                ? DateFormat.yMMMd().format(createdAt.toDate())
                : 'N/A';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(name.toString().substring(0, 1).toUpperCase()),
                ),
                title: Text(name.toString()),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('Phone: $phone')),
                    Text(context.tr('Business: $businessDomain')),
                    Text(context.tr('Joined: $dateStr')),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
    */

    final usersAsync = ref.watch(adminUsersStreamProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(context.tr('Error: $err'))),
      data: (users) {
        if (users.isEmpty) {
          return Center(child: Text(context.tr('No users found')));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final name = (user.name?.isNotEmpty ?? false)
                ? user.name!
                : context.tr('Unknown');
            final phone = user.phoneNumber.isNotEmpty
                ? user.phoneNumber
                : context.tr('N/A');
            final businessDomain = user.businessDomain ?? context.tr('N/A');
            final dateStr = DateFormat.yMMMd().format(user.createdAt);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(name.substring(0, 1).toUpperCase()),
                ),
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('Phone: $phone')),
                    Text(context.tr('Business: $businessDomain')),
                    Text(context.tr('Joined: $dateStr')),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
