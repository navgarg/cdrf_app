import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';
import 'package:nariudyam/l10n/dynamic_localizations.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import 'package:nariudyam/providers/inventory_providers.dart';
import 'package:nariudyam/providers/locale_provider.dart';
import 'package:nariudyam/providers/services_providers.dart';
import 'package:nariudyam/providers/transaction_providers.dart';
import 'package:nariudyam/services/api/analytics_service.dart';
import 'package:nariudyam/services/voice/voice_output_service.dart';

class AdvancedAnalyticsScreen extends ConsumerWidget {
  const AdvancedAnalyticsScreen({super.key});

  Future<void> _speakSummary(
    BuildContext context,
    WidgetRef ref,
    String summary,
  ) async {
    final spokenText = await VoiceOutputService.instance.speak(
      text: summary,
      languageCode: ref.read(localeProvider).languageCode,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(spokenText)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(allTransactionsStreamProvider);

    return transactionsAsync.when(
      data: (_) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallMetricsSection(ref, theme, context),
              const SizedBox(height: 24),

              _buildSectionTitle(context.tr('Revenue by Product/Service'), theme),
              const SizedBox(height: 12),
              _buildProductRevenueChart(ref, theme, context),
              const SizedBox(height: 24),

              _buildSectionTitle(context.tr('Revenue by Payment Mode'), theme),
              const SizedBox(height: 12),
              _buildPaymentModeChart(ref, theme, context),
              const SizedBox(height: 24),

              _buildSectionTitle(context.tr('Inventory Reorder Alerts'), theme),
              const SizedBox(height: 12),
              _buildInventoryReorderList(ref, theme, context),
              const SizedBox(height: 24),

              _buildSectionTitle(context.tr('Top Products by Revenue'), theme),
              const SizedBox(height: 12),
              _buildTopProductsList(ref, theme, context),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(context.tr('Error: $err'))),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOverallMetricsSection(
      WidgetRef ref, ThemeData theme, BuildContext context) {
    final metrics = ref.watch(overallMetricsProvider);

    if (metrics.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            context.tr('Overall Performance'),
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricCard(
                context.tr('Total Revenue'),
                '₹${metrics['totalRevenue']?.toStringAsFixed(0) ?? '0'}',
                Icons.attach_money,
                Colors.white,
              ),
              _buildMetricCard(
                context.tr('Total Transactions'),
                '${metrics['totalTransactions']?.toInt() ?? 0}',
                Icons.receipt_long,
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color.withValues(alpha: 0.9),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProductRevenueChart(
      WidgetRef ref, ThemeData theme, BuildContext context) {
    final user = ref.watch(userProvider);
    final domain = user?.businessDomain?.trim().toLowerCase();
    final isService = domain == 'beauty parlor';

    final itemsAsync =
        isService ? ref.watch(serviceItemsProvider) : ref.watch(inventoryItemsProvider);

    if (itemsAsync.isLoading) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (itemsAsync.hasError) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(child: Text(context.tr('Error loading items'))),
      );
    }

    final productsResult = ref.watch(productRevenueDataProvider);
    if (productsResult.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(child: Text(context.tr('No sales data available'))),
      );
    }

    final data = productsResult.take(5).toList();
    final totalRevenue = data.fold<double>(0, (sum, d) => sum + d.revenue);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    final summary =
        'Revenue by product summary. The top ${data.length} items contribute a total of rupees '
        '${totalRevenue.toStringAsFixed(0)}. The leading item is ${data.first.productName} '
        'with rupees ${data.first.revenue.toStringAsFixed(0)} in revenue.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('Summary'),
                style: theme.textTheme.titleMedium,
              ),
              IconButton(
                tooltip: context.tr('Listen to graph summary'),
                onPressed: () => _speakSummary(context, ref, summary),
                icon: const Icon(Icons.volume_up_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final percentage = totalRevenue > 0 ? ((item.revenue / totalRevenue) * 100) : 0;
                  return PieChartSectionData(
                    value: item.revenue,
                    title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                    color: colors[index % colors.length],
                    radius: 70,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${item.productName} (₹${item.revenue.toStringAsFixed(0)})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentModeChart(
      WidgetRef ref, ThemeData theme, BuildContext context) {
    final data = ref.watch(paymentModeDataProvider);
    if (data.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(child: Text(context.tr('No payment data available'))),
      );
    }

    final colors = {
      PaymentMethod.cash: Colors.green,
      PaymentMethod.qr: Colors.blue,
    };

    final labels = {
      PaymentMethod.cash: context.tr('Cash'),
      PaymentMethod.qr: context.tr('QR/UPI'),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('Summary'),
                style: theme.textTheme.titleMedium,
              ),
              IconButton(
                tooltip: context.tr('Listen to graph summary'),
                onPressed: () {
                  final totalRevenue =
                      data.fold<double>(0, (sum, item) => sum + item.revenue);
                  final leading = data.first;
                  final leadingLabel = labels[leading.method] ?? 'Unknown';
                  final summary =
                      'Payment mode summary. Total revenue across payment modes is rupees '
                      '${totalRevenue.toStringAsFixed(0)}. The leading payment mode is '
                      '$leadingLabel with rupees ${leading.revenue.toStringAsFixed(0)} '
                      'and ${leading.transactionCount} transactions.';
                  _speakSummary(context, ref, summary);
                },
                icon: const Icon(Icons.volume_up_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // By Revenue
          Text(
            context.tr('By Revenue'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: data.map((item) {
                  final totalRevenue =
                      data.fold<double>(0, (sum, d) => sum + d.revenue);
                  final percentage = totalRevenue > 0 ? ((item.revenue / totalRevenue) * 100) : 0;
                  return PieChartSectionData(
                    value: item.revenue,
                    title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                    color: colors[item.method] ?? Colors.grey,
                    radius: 70,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: data.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[item.method] ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${labels[item.method] ?? context.tr('Unknown')} (₹${item.revenue.toStringAsFixed(0)})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          // By Transaction Count
          Text(
            context.tr('By Transaction Count'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: data.map((item) {
                  final totalTransactions =
                      data.fold<int>(0, (sum, d) => sum + d.transactionCount);
                  final percentage = totalTransactions > 0 ? ((item.transactionCount / totalTransactions) * 100) : 0;
                  return PieChartSectionData(
                    value: item.transactionCount.toDouble(),
                    title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                    color: colors[item.method] ?? Colors.grey,
                    radius: 70,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: data.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[item.method] ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${labels[item.method] ?? context.tr('Unknown')} (${item.transactionCount} txns)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryReorderList(
      WidgetRef ref, ThemeData theme, BuildContext context) {
    final itemsAsync = ref.watch(inventoryItemsProvider);
    if (itemsAsync.isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (itemsAsync.hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(child: Text(context.tr('Error loading inventory'))),
      );
    }

    final inventoryResult = ref.watch(inventoryReorderDataProvider);
    if (inventoryResult.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(context.tr('✓ All inventory items are well stocked!')),
        ),
      );
    }

    final data = inventoryResult;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr('Items currently at or below reorder threshold'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = data[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withValues(alpha: 0.2),
                  child: const Icon(Icons.warning, color: Colors.red, size: 20),
                ),
                title: Text(item.productName),
                subtitle: Text(
                  '${context.tr('Current')}: ${item.currentStock} | ${context.tr('Threshold')}: ${item.reorderThreshold}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.tr('Low Stock'),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsList(
      WidgetRef ref, ThemeData theme, BuildContext context) {
    final user = ref.watch(userProvider);
    final domain = user?.businessDomain?.trim().toLowerCase();
    final isService = domain == 'beauty parlor';

    final itemsAsync =
        isService ? ref.watch(serviceItemsProvider) : ref.watch(inventoryItemsProvider);

    if (itemsAsync.isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (itemsAsync.hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(child: Text(context.tr('Error loading items'))),
      );
    }

    final productsResult = ref.watch(productRevenueDataProvider);
    if (productsResult.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(child: Text(context.tr('No sales data available'))),
      );
    }

    final data = productsResult.take(10).toList();
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = data[index];
          final rankColors = [
            Colors.amber,
            Colors.grey,
            Colors.brown,
          ];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: index < 3
                  ? rankColors[index].withValues(alpha: 0.2)
                  : theme.colorScheme.primaryContainer,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: index < 3 ? rankColors[index] : null,
                ),
              ),
            ),
            title: Text(item.productName),
            subtitle: Text(
              '${context.tr('Sales')}: ${item.salesCount} | ${context.tr('Profit')}: ₹${item.profit.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              '₹${item.revenue.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          );
        },
      ),
    );
  }
}
