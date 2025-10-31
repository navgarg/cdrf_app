import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nariudyam/services/api/analytics_service.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';

class AdvancedAnalyticsScreen extends ConsumerWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsService = ref.watch(analyticsServiceProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Metrics
          _buildOverallMetricsSection(analyticsService, theme),
          const SizedBox(height: 24),

          // Revenue by Product/Service
          _buildSectionTitle('Revenue by Product/Service', theme),
          const SizedBox(height: 12),
          _buildProductRevenueChart(analyticsService, theme),
          const SizedBox(height: 24),

          // Revenue by Payment Mode
          _buildSectionTitle('Revenue by Payment Mode', theme),
          const SizedBox(height: 12),
          _buildPaymentModeChart(analyticsService, theme),
          const SizedBox(height: 24),

          // Inventory Reorder Alerts
          _buildSectionTitle('Inventory Reorder Alerts', theme),
          const SizedBox(height: 12),
          _buildInventoryReorderList(analyticsService, theme),
          const SizedBox(height: 24),

          // Top Products by Revenue
          _buildSectionTitle('Top Products by Revenue', theme),
          const SizedBox(height: 12),
          _buildTopProductsList(analyticsService, theme),
        ],
      ),
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
      AnalyticsService analyticsService, ThemeData theme) {
    return StreamBuilder<Map<String, double>>(
      stream: analyticsService.getOverallMetrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No data available');
        }

        final metrics = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Text(
                'Overall Performance',
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
                    'Total Revenue',
                    '₹${metrics['totalRevenue']?.toStringAsFixed(0) ?? '0'}',
                    Icons.attach_money,
                    Colors.white,
                  ),
                  _buildMetricCard(
                    'Total Transactions',
                    '${metrics['totalTransactions']?.toInt() ?? 0}',
                    Icons.receipt_long,
                    Colors.white,
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProductRevenueChart(
      AnalyticsService analyticsService, ThemeData theme) {
    return StreamBuilder<List<ProductRevenueData>>(
      stream: analyticsService.getProductRevenueStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: 250,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(child: Text('No sales data available')),
          );
        }

        final data = snapshot.data!.take(5).toList(); // Top 5
        final colors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.red,
        ];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return PieChartSectionData(
                        value: item.revenue,
                        title:
                            '${((item.revenue / data.fold<double>(0, (sum, d) => sum + d.revenue)) * 100).toStringAsFixed(0)}%',
                        color: colors[index % colors.length],
                        radius: 70,
                        titleStyle: const TextStyle(
                          fontSize: 14,
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
      },
    );
  }

  Widget _buildPaymentModeChart(
      AnalyticsService analyticsService, ThemeData theme) {
    return StreamBuilder<List<PaymentModeData>>(
      stream: analyticsService.getPaymentModeStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: 250,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(child: Text('No payment data available')),
          );
        }

        final data = snapshot.data!;
        final colors = {
          PaymentMethod.cash: Colors.green,
          PaymentMethod.qr: Colors.blue,
        };

        final labels = {
          PaymentMethod.cash: 'Cash',
          PaymentMethod.qr: 'QR/UPI',
        };

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              // By Revenue
              Text(
                'By Revenue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: data.map((item) {
                      final totalRevenue =
                          data.fold<double>(0, (sum, d) => sum + d.revenue);
                      return PieChartSectionData(
                        value: item.revenue,
                        title:
                            '${((item.revenue / totalRevenue) * 100).toStringAsFixed(0)}%',
                        color: colors[item.method] ?? Colors.grey,
                        radius: 70,
                        titleStyle: const TextStyle(
                          fontSize: 14,
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
                        '${labels[item.method] ?? 'Unknown'} (₹${item.revenue.toStringAsFixed(0)})',
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
                'By Transaction Count',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: data.map((item) {
                      final totalTransactions = data.fold<int>(
                          0, (sum, d) => sum + d.transactionCount);
                      return PieChartSectionData(
                        value: item.transactionCount.toDouble(),
                        title:
                            '${((item.transactionCount / totalTransactions) * 100).toStringAsFixed(0)}%',
                        color: colors[item.method] ?? Colors.grey,
                        radius: 70,
                        titleStyle: const TextStyle(
                          fontSize: 14,
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
                        '${labels[item.method] ?? 'Unknown'} (${item.transactionCount} txns)',
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
      },
    );
  }

  Widget _buildInventoryReorderList(
      AnalyticsService analyticsService, ThemeData theme) {
    return StreamBuilder<List<InventoryReorderData>>(
      stream: analyticsService.getInventoryReorderStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text('✓ All inventory items are well stocked!'),
            ),
          );
        }

        final data = snapshot.data!;
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
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Items currently at or below reorder threshold',
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
                      backgroundColor: Colors.red.withOpacity(0.2),
                      child: const Icon(Icons.warning,
                          color: Colors.red, size: 20),
                    ),
                    title: Text(item.productName),
                    subtitle: Text(
                      'Current: ${item.currentStock} | Threshold: ${item.reorderThreshold}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Low Stock',
                        style: TextStyle(
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
      },
    );
  }

  Widget _buildTopProductsList(
      AnalyticsService analyticsService, ThemeData theme) {
    return StreamBuilder<List<ProductRevenueData>>(
      stream: analyticsService.getProductRevenueStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(child: Text('No sales data available')),
          );
        }

        final data = snapshot.data!.take(10).toList();
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
                      ? rankColors[index].withOpacity(0.2)
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
                  'Sales: ${item.salesCount} | Profit: ₹${item.profit.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  '₹${item.revenue.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
