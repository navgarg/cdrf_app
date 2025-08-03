import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api/auth_service.dart';
import '../models/user.dart';
import '../services/general/dashboard_service.dart';

enum DashboardView { daily, weekly, monthly }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardView _dashboardView = DashboardView.daily;

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userProvider);
    final dashboardService = ref.watch(dashboardServiceProvider);

    List<DailySummary> data;
    switch (_dashboardView) {
      case DashboardView.daily:
        data = dashboardService.getDailyData();
        break;
      case DashboardView.weekly:
        data = dashboardService.getWeeklyData();
        break;
      case DashboardView.monthly:
        data = dashboardService.getMonthlyData();
        break;
    }

    return userModel == null
        ? const Center(child: CircularProgressIndicator())
        : _buildDashboard(context, userModel, data);
  }

  Widget _buildDashboard(BuildContext context, UserModel user, List<DailySummary> data) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.waving_hand,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Welcome text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello!',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      
            _buildToggleButtons(),
            const SizedBox(height: 24),
            // Placeholder for charts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.sales);
                    }).toList(),
                    isCurved: true,
                    barWidth: 5,
                    color: Theme.of(context).colorScheme.primary,
                    belowBarData: BarAreaData(show: false),
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            // const SizedBox(height: 16),
            // _buildInfoItem(Icons.phone, 'Phone Number', user.phoneNumber),
            // _buildInfoItem(
            //   Icons.calendar_today,
            //   'Account created on:',
            //   _formatDate(user.createdAt),
            // ),
            // _buildInfoItem(
            //   Icons.access_time,
            //   'Last login: ',
            //   _formatDate(user.lastLoginAt),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  Widget _buildToggleButtons() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ToggleButtons(
        isSelected: [
          _dashboardView == DashboardView.daily,
          _dashboardView == DashboardView.weekly,
          _dashboardView == DashboardView.monthly,
        ],
        onPressed: (int index) {
          setState(() {
            if (index == 0) _dashboardView = DashboardView.daily;
            if (index == 1) _dashboardView = DashboardView.weekly;
            if (index == 2) _dashboardView = DashboardView.monthly;
          });
        },
        borderRadius: BorderRadius.circular(20.0),
        selectedBorderColor: theme.colorScheme.primary,
        selectedColor: Colors.white,
        fillColor: theme.colorScheme.primary,
        color: theme.colorScheme.primary,
        constraints: BoxConstraints(
          minHeight: 40.0,
          minWidth: (MediaQuery.of(context).size.width - 48) / 3,
        ),
        children: const [Text('Daily'), Text('Weekly'), Text('Monthly')],
      ),
    );
  }
}
