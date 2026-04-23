import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/admin/admin_analytics_service.dart';
import '../../l10n/dynamic_localizations.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() =>
      _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  late Future<AdminAnalyticsData> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    final analyticsService = ref.read(adminAnalyticsServiceProvider);
    setState(() {
      _analyticsFuture = analyticsService.fetchAnalyticsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<AdminAnalyticsData>(
      future: _analyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ??
            AdminAnalyticsData(
              totalUsers: 0,
              activeUsers: 0,
              totalTransactions: 0,
              totalResources: 0,
              totalRevenue: 0.0,
            );

        final currencyFormat = NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 0,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('User Analytics'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadAnalytics,
                    tooltip: context.tr('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildAnalyticsCard(
                context,
                context.tr('Total Users'),
                data.totalUsers.toString(),
                Icons.people,
                Colors.blue,
                context.tr('All registered users'),
              ),
              const SizedBox(height: 12),
              _buildAnalyticsCard(
                context,
                context.tr('Active Users (7 days)'),
                data.activeUsers.toString(),
                Icons.online_prediction,
                Colors.green,
                context.tr('Users active in last 7 days'),
              ),
              const SizedBox(height: 12),
              _buildAnalyticsCard(
                context,
                context.tr('Total Transactions'),
                data.totalTransactions.toString(),
                Icons.receipt_long,
                Colors.orange,
                context.tr('All time transactions'),
              ),
              const SizedBox(height: 12),
              _buildAnalyticsCard(
                context,
                context.tr('Resources Uploaded'),
                data.totalResources.toString(),
                Icons.folder,
                Colors.purple,
                context.tr('Total files in resource center'),
              ),
              const SizedBox(height: 12),
              _buildAnalyticsCard(
                context,
                context.tr('Total Revenue'),
                currencyFormat.format(data.totalRevenue),
                Icons.currency_rupee,
                Colors.teal,
                context.tr('Combined revenue from all users'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
