import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nariudyam/components/dashboard_chart.dart';
import 'package:go_router/go_router.dart';
import '../services/api/auth_service.dart';
import '../models/user.dart';
import '../services/api/dashboard_service.dart';
import '../components/generic_list_tile.dart';
import 'package:nariudyam/l10n/app_localizations.dart';

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
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

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
        : _buildDashboard(context, userModel, dataStream, appLocalizations);
  }

  Widget _buildDashboard(
      BuildContext context,
      UserModel user,
      Stream<List<DailySummary>> dataStream,
      AppLocalizations appLocalizations) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildToggleButtons(),
          const SizedBox(height: 24),
          StreamBuilder<List<DailySummary>>(
              stream: dataStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildDateNavigator(null);
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    children: [
                      _buildDateNavigator([]),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text('No data available for this period.'),
                      ),
                    ],
                  );
                }
                final data = snapshot.data!;
                final totalProfit =
                    data.fold<double>(0.0, (sum, item) => sum + item.profit);
                // final todayProfit = data.isNotEmpty
                //     ? data.last.profit
                //     : 0.0; // Assuming last item is today's or most recent
                final bestProfit = data.isNotEmpty
                    ? data.map((e) => e.profit).reduce((a, b) => a > b ? a : b)
                    : 0.0;

                return Column(
                  children: [
                    _buildDateNavigator(data),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DashboardChart(
                        data: data,
                        dashboardView: _dashboardView,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          // _buildSummaryRow(appLocalizations.today,
                          //     todayProfit.toStringAsFixed(2)),
                          // const Divider(),
                          _buildSummaryRow(appLocalizations.best,
                              bestProfit.toStringAsFixed(2)),
                          const Divider(),
                          _buildSummaryRow(appLocalizations.total,
                              totalProfit.toStringAsFixed(2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Container(
                    //   padding: const EdgeInsets.all(16),
                    //   decoration: BoxDecoration(
                    //     color: Theme.of(context).colorScheme.primaryContainer,
                    //     borderRadius: BorderRadius.circular(15),
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //     children: [
                    //       Column(
                    //         children: [
                    //           Text(
                    //             appLocalizations.revenue,
                    //             style: Theme.of(context).textTheme.titleMedium,
                    //           ),
                    //           Text(
                    //             '₹ 0',
                    //             style: Theme.of(context)
                    //                 .textTheme
                    //                 .headlineMedium
                    //                 ?.copyWith(
                    //                   color: Colors.green,
                    //                 ),
                    //           ),
                    //         ],
                    //       ),
                    //       Column(
                    //         children: [
                    //           Text(
                    //             appLocalizations.expenses,
                    //             style: Theme.of(context).textTheme.titleMedium,
                    //           ),
                    //           Text(
                    //             '₹ 0',
                    //             style: Theme.of(context)
                    //                 .textTheme
                    //                 .headlineMedium
                    //                 ?.copyWith(
                    //                   color: Colors.red,
                    //                 ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 24),
                    // Resource Centre tile (navigates to separate page)
                    GenericListTile(
                      leading: Icon(Icons.folder,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28),
                      titleWidget: const Text(
                        'Resource Centre',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey.shade600),
                      onTap: () => context.push('/resource_centre'),
                    ),
<<<<<<< HEAD
                    const SizedBox(height: 24),
                    // Advanced Analytics tile
                    GenericListTile(
                      leading: Icon(Icons.analytics,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28),
                      titleWidget: const Text(
                        'Advanced Analytics',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey.shade600),
                      onTap: () => context.push('/advanced_analytics'),
                    ),
                    const SizedBox(height: 12),
                    // Resource Centre tile (navigates to separate page)
                    GenericListTile(
                      leading: Icon(Icons.folder,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28),
                      titleWidget: const Text(
                        'Resource Centre',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey.shade600),
                      onTap: () => context.push('/resource_centre'),
                    ),
=======
>>>>>>> 70d13de923a2b497db3a3de53f2be652ef11d98f
                  ],
                );
              }),
        ]),
      ),
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
        return DateFormat('MMM dd, yyyy').format(firstDate);
      // if (firstDate.month == lastDate.month) {
      //   return '${DateFormat('MMM dd').format(firstDate)}-${DateFormat('dd, yyyy').format(lastDate)}';
      // } else {
      //   return '${DateFormat('MMM dd').format(firstDate)}-${DateFormat('MMM dd, yyyy').format(lastDate)}';
      // }
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

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '₹ $value',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
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
