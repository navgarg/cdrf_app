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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final salesColor = Color.lerp(primary, Colors.deepOrange, 0.35)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.35,
        child: data.isEmpty
            ? const Center(child: Text('No data available.'))
            : LineChart(
                LineChartData(
                  backgroundColor: Colors.transparent,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: _gridInterval(data),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.primary.withAlpha(28),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: theme.colorScheme.onSurface.withAlpha(22),
                      strokeWidth: 1,
                      dashArray: [6, 6],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color:
                                    theme.colorScheme.onSurface.withAlpha(170),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                      axisNameWidget: Text(
                        'Sales (₹)',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withAlpha(190),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      axisNameSize: 20,
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize:
                            dashboardView == DashboardView.daily ? 78 : 62,
                        interval: 1.0,
                        getTitlesWidget: (value, meta) => _getBottomTitles(
                          value,
                          meta,
                          data,
                          context,
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
                          FlLine(color: salesColor, strokeWidth: 2),
                          FlDotData(
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              radius: 6,
                              color: salesColor,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
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
                      color: salesColor,
                      gradient: LinearGradient(
                        colors: [
                          salesColor,
                          theme.colorScheme.primary,
                        ],
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            salesColor.withAlpha(58),
                            salesColor.withAlpha(4),
                          ],
                        ),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 3.5,
                          color: salesColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _getBottomTitles(
    double value,
    TitleMeta meta,
    List<DailySummary> data,
    BuildContext context,
  ) {
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

          text = '$startHour12$startAmPm\n$endHour12$endAmPm';
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
        space: 10,
        child: SizedBox(
          width: dashboardView == DashboardView.daily ? 46 : 58,
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: dashboardView == DashboardView.daily ? 2 : 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: dashboardView == DashboardView.daily ? 12 : 13,
              fontWeight: FontWeight.w600,
              height: 1.05,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            ),
          ),
        ),
      );
    }
    return SideTitleWidget(
      meta: meta,
      child: const Text(''),
    );
  }

  double _gridInterval(List<DailySummary> data) {
    final maxSales = data.fold<double>(
      0,
      (max, item) => item.sales > max ? item.sales : max,
    );
    if (maxSales <= 0) return 1;
    return (maxSales / 4).clamp(1, double.infinity);
  }
}
