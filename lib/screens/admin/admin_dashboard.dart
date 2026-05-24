import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import 'package:nariudyam/providers/admin_providers.dart';
import '../../services/general/excel_service.dart';
import '../../config/admin_config.dart';
import '../../components/generic_list_tile.dart';
import '../../l10n/dynamic_localizations.dart';

// firebase (previous implementation)
// import '../../services/api/auth_service.dart';
// import '../../services/admin/admin_analytics_service.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(userProvider);
    final analyticsService = ref.watch(adminAnalyticsServiceProvider);
    final excelService = ref.watch(excelServiceProvider);
    final isAdmin = AdminConfig.isAdmin(user?.phoneNumber ?? '');

    return FutureBuilder<Map<String, dynamic>>(
      future: analyticsService.getDashboardStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ??
            {
              'totalUsers': 0,
              'totalResources': 0,
              'totalRevenue': 0.0,
              'activeToday': 0,
            };

        final currencyFormat = NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 0,
        );

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin Portal heading
                Text(
                  context.tr('Admin Portal'),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  context.tr('Welcome, ${user?.name ?? 'Admin'}'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // Quick stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('Overview'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        context.tr('Total Users'),
                        stats['totalUsers'].toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        context.tr('Resources'),
                        stats['totalResources'].toString(),
                        Icons.folder,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        context.tr('Total Revenue'),
                        currencyFormat.format(stats['totalRevenue']),
                        Icons.currency_rupee,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        context.tr('Active Today'),
                        stats['activeToday'].toString(),
                        Icons.trending_up,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                if (isAdmin) ...[
                  GenericListTile(
                    leading: Icon(Icons.upload_file,
                        color: theme.colorScheme.primary, size: 28),
                    titleWidget: Text(
                      context.tr('Add Resource to Resource Centre'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey.shade600),
                    onTap: () => context.go('/admin/resources'),
                  ),
                  const SizedBox(height: 16),
                ],

                // Export Analytics button
                if (isAdmin)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        excelService.exportAllAnalyticsToExcel();
                      },
                      icon: const Icon(Icons.download),
                      label: Text(context.tr('Export Analytics')),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.white,
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                if (isAdmin) const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      ref.read(authServiceProvider).signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(context.tr('Sign Out')),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.white,
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
