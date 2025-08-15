import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
  DateTime _focusedDate = DateTime.now();

  void _navigate(int days, int weeks, int months) {
    setState(() {
      if (days != 0) {
        _focusedDate = _focusedDate.add(Duration(days: days));
      } else if (weeks != 0) {
        _focusedDate = _focusedDate.add(Duration(days: weeks * 7));
      } else if (months != 0) {
        _focusedDate = DateTime(
          _focusedDate.year,
          _focusedDate.month + months,
          _focusedDate.day,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userProvider);
    final dashboardService = ref.watch(dashboardServiceProvider);

    Stream<List<DailySummary>> dataStream = Stream.value([]);
    switch (_dashboardView) {
      case DashboardView.daily:
            dataStream = dashboardService.getDailyData(_focusedDate);
            break;
          case DashboardView.weekly:
            dataStream = dashboardService.getWeeklyData(_focusedDate);
            break;
          case DashboardView.monthly:
            dataStream = dashboardService.getMonthlyData(_focusedDate);
            break;
    }

    return userModel == null
        ? const Center(child: CircularProgressIndicator())
        : _buildDashboard(context, userModel, dataStream);
  }

  Widget _buildDashboard(BuildContext context, UserModel user, Stream<List<DailySummary>> dataStream) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToggleButtons(),
            const SizedBox(height: 24),
            StreamBuilder<List<DailySummary>>(
              stream: dataStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildDateNavigator(null);
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildDateNavigator([]);
                }
                final data = snapshot.data!;
                return _buildDateNavigator(data);
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: StreamBuilder<List<DailySummary>>(
              stream: dataStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('No data available.'));
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text('No data available.'));
                }
                return LineChart(
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
                          getTitlesWidget: (value, meta) => _getBottomTitles(value, meta, data),
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
                      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
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
                      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((spotIndex) {
                          return TouchedSpotIndicatorData(
                            const FlLine(color: Colors.blue, strokeWidth: 2),
                            FlDotData(
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(radius: 6, color: Colors.blue),
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
                );
              },
            ),
          ),
            ),
            const SizedBox(height: 24),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta, List<DailySummary> data) {
    final intIndex = value.toInt();
    // Check if the value is an integer and within the bounds of the data list
    if (value == intIndex.toDouble() && intIndex >= 0 && intIndex < data.length) {
      final index = intIndex;

    String text;
    switch (_dashboardView) {
      case DashboardView.daily:
        text = '${data[index].date.day}';
        break;
      case DashboardView.weekly:
        DateTime dateForWeek = data[index].date;
        DateTime startOfWeek = dateForWeek.subtract(Duration(days: dateForWeek.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
        text = '${DateFormat('dd').format(startOfWeek)}-${DateFormat('dd MMM').format(endOfWeek)}';
        break;
      case DashboardView.monthly:
        text = DateFormat('MMM').format(data[index].date);
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

  Widget _buildDateNavigator(List<DailySummary>? data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              switch (_dashboardView) {
                case DashboardView.daily:
                  _navigate(-1, 0, 0);
                  break;
                case DashboardView.weekly:
                  _navigate(0, -1, 0);
                  break;
                case DashboardView.monthly:
                  _navigate(0, 0, -1);
                  break;
              }
            },
          ),
          Text(
            _getNavigatorHeaderText(data),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () {
              switch (_dashboardView) {
                case DashboardView.daily:
                  _navigate(1, 0, 0);
                  break;
                case DashboardView.weekly:
                  _navigate(0, 1, 0);
                  break;
                case DashboardView.monthly:
                  _navigate(0, 0, 1);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  String _getNavigatorHeaderText(List<DailySummary>? data) {
    if (data == null || data.isEmpty) {
      return '';
    }

    final firstDate = data.first.date;
    final lastDate = data.last.date;

    switch (_dashboardView) {
      case DashboardView.daily:
        if (firstDate.month == lastDate.month) {
          return '${DateFormat('MMM dd').format(firstDate)}-${DateFormat('dd, yyyy').format(lastDate)}';
        } else {
          return '${DateFormat('MMM dd').format(firstDate)}-${DateFormat('MMM dd, yyyy').format(lastDate)}';
        }
      case DashboardView.weekly:
        if (firstDate.year == lastDate.year) {
          return '${DateFormat('MMM dd').format(firstDate)} - ${DateFormat('MMM dd, yyyy').format(lastDate)}';
        } else {
          return '${DateFormat('MMM yyyy').format(firstDate)} - ${DateFormat('MMM yyyy').format(lastDate)}';
        }
      case DashboardView.monthly:
        if (firstDate.year == lastDate.year) {
          return '${DateFormat('MMM').format(firstDate)} - ${DateFormat('MMM, yyyy').format(lastDate)}';
        } else {
          return '${DateFormat('MMM yyyy').format(firstDate)} - ${DateFormat('MMM yyyy').format(lastDate)}';
        }
    }
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
