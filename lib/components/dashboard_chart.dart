import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api/dashboard_service.dart';
import '../screens/dashboard.dart';

class DashboardChart extends StatelessWidget {
  final List<DailySummary> data;
  final DashboardView dashboardView;

  const DashboardChart({
    super.key,
    required this.data,
    required this.dashboardView,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.35,
        child: data.isEmpty
            ? const Center(child: Text('No data available.'))
            : LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(value.toInt().toString()),
                          );
                        },
                      ),
                      axisNameWidget: const Text('Sales (₹)'),
                      axisNameSize: 20,
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: 1.0,
                        getTitlesWidget: (value, meta) => _getBottomTitles(
                          value,
                          meta,
                          data,
                        ),
                      ),
                      axisNameSize: 20,
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      if (event is FlTapUpEvent && touchResponse != null) {
                        final spot = touchResponse.lineBarSpots?.first;
                        if (spot != null) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < data.length) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Sales: ₹${data[index].sales.toStringAsFixed(2)}\nProfit: ₹${data[index].profit.toStringAsFixed(2)}',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    getTouchedSpotIndicator:
                        (LineChartBarData barData, List<int> spotIndexes) {
                      return spotIndexes.map((spotIndex) {
                        return TouchedSpotIndicatorData(
                          const FlLine(color: Colors.blue, strokeWidth: 2),
                          FlDotData(
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                    radius: 6, color: Colors.blue),
                          ),
                        );
                      }).toList();
                    },
                  ),
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
    );
  }

  Widget _getBottomTitles(
      double value, TitleMeta meta, List<DailySummary> data) {
    final intIndex = value.toInt();
    // Check if the value is an integer and within the bounds of the data list
    if (value == intIndex.toDouble() &&
        intIndex >= 0 &&
        intIndex < data.length) {
      final index = intIndex;

      String text;
      switch (dashboardView) {
        case DashboardView.daily:
          final hour = data[index].date.hour;
          String startHour12 = (hour % 12 == 0 ? 12 : hour % 12).toString();
          String startAmPm = hour < 12 ? 'AM' : 'PM';

          int endHour24 = hour + 4;
          String endHour12 =
              (endHour24 % 12 == 0 ? 12 : endHour24 % 12).toString();
          String endAmPm = endHour24 < 12 ? 'AM' : 'PM';

          text = '$startHour12$startAmPm-$endHour12$endAmPm';
          break;
        case DashboardView.weekly:
          text = '${data[index].date.day}';
          break;
        case DashboardView.monthly:
          DateTime dateForWeek = data[index].date;
          DateTime startOfWeek =
              dateForWeek.subtract(Duration(days: dateForWeek.weekday - 1));
          DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
          text =
              '${DateFormat('dd').format(startOfWeek)}-${DateFormat('dd MMM').format(endOfWeek)}';
          break;
      }

      return SideTitleWidget(
        meta: meta,
        child: Text(text),
      );
    }
    return SideTitleWidget(
      meta: meta,
      child: const Text(''),
    );
  }
}
