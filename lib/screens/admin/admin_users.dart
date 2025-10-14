import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data?.docs ?? [];

        if (users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final name = userData['name'] ?? 'Unknown';
            final phone = userData['phoneNumber'] ?? 'N/A';
            final businessDomain = userData['businessDomain'] ?? 'N/A';
            final createdAt = userData['createdAt'] as Timestamp?;
            final dateStr = createdAt != null
                ? DateFormat.yMMMd().format(createdAt.toDate())
                : 'N/A';

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
                    Text('Phone: $phone'),
                    Text('Business: $businessDomain'),
                    Text('Joined: $dateStr'),
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
