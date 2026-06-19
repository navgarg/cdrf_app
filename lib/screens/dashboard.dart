import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:nariudyam/components/dashboard_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import 'package:nariudyam/providers/transaction_providers.dart';
import '../models/user.dart';
import '../services/api/dashboard_service.dart';
import '../components/generic_list_tile.dart';
import '../l10n/dynamic_localizations.dart';
import '../providers/locale_provider.dart';
import '../services/translation_service.dart';
import '../services/voice/voice_output_service.dart';

// firebase (previous implementation)
// import '../services/api/auth_service.dart';

enum DashboardView { daily, weekly, monthly }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardView _dashboardView = DashboardView.daily;
  DateTime _focusedDate = DateTime.now();
  StreamSubscription? _translationSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // Listen for translation updates and trigger rebuild
    _translationSubscription =
        TranslationService().onTranslationUpdated.listen((_) {
      // Debounce rebuilds to avoid performance issues
      if (_refreshTimer?.isActive ?? false) return;

      _refreshTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            // Trigger rebuild to show new translations
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _translationSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

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

  Future<void> _speakDashboardSummary(List<DailySummary> data) async {
    if (data.isEmpty) return;

    final totalSales = data.fold<double>(0, (sum, item) => sum + item.sales);
    final totalProfit = data.fold<double>(0, (sum, item) => sum + item.profit);
    final bestEntry = data.reduce((a, b) => a.sales >= b.sales ? a : b);

    final periodLabel = switch (_dashboardView) {
      DashboardView.daily => 'today',
      DashboardView.weekly => 'this weekly view',
      DashboardView.monthly => 'this monthly view',
    };

    final summary =
        'Summary for $periodLabel. Total sales are rupees ${totalSales.toStringAsFixed(0)}. '
        'Total profit is rupees ${totalProfit.toStringAsFixed(0)}. '
        'The highest sales point is rupees ${bestEntry.sales.toStringAsFixed(0)} '
        'with profit rupees ${bestEntry.profit.toStringAsFixed(0)}.';

    final spokenText = await VoiceOutputService.instance.speak(
      text: summary,
      languageCode: ref.read(localeProvider).languageCode,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(spokenText)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userProvider);
    final dashboardService = ref.watch(dashboardServiceProvider);
    final transactionsAsync = ref.watch(allTransactionsStreamProvider);

    return userModel == null
        ? const Center(child: CircularProgressIndicator())
        : transactionsAsync.when(
            data: (transactions) {
              List<DailySummary> data = [];
              switch (_dashboardView) {
                case DashboardView.daily:
                  data =
                      dashboardService.getDailyData(transactions, _focusedDate);
                  break;
                case DashboardView.weekly:
                  data = dashboardService.getWeeklyData(
                      transactions, _focusedDate);
                  break;
                case DashboardView.monthly:
                  data = dashboardService.getMonthlyData(
                      transactions, _focusedDate);
                  break;
              }
              return _buildDashboard(context, userModel, data);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text(context.tr('Error: $err'))),
          );
  }

  Widget _buildDashboard(
      BuildContext context, UserModel user, List<DailySummary> data) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildToggleButtons(),
          const SizedBox(height: 24),
          if (data.isEmpty) ...[
            _buildDateNavigator([]),
            const SizedBox(height: 16),
            Center(
              child: Text(context.tr('No data available for this period.')),
            ),
          ] else ...[
            Builder(builder: (context) {
              final totalSales =
                  data.fold<double>(0.0, (sum, item) => sum + item.sales);
              final bestSales = data.isNotEmpty
                  ? data.map((e) => e.sales).reduce((a, b) => a > b ? a : b)
                  : 0.0;

              return Column(
                children: [
                  _buildDateNavigator(data),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('Graph Summary'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            IconButton(
                              tooltip: context.tr('Listen to graph summary'),
                              onPressed: () => _speakDashboardSummary(data),
                              icon: const Icon(Icons.volume_up_outlined),
                            ),
                          ],
                        ),
                        DashboardChart(
                          data: data,
                          dashboardView: _dashboardView,
                        ),
                      ],
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
                        _buildSummaryRow(
                            context.tr('Best'), bestSales.toStringAsFixed(2)),
                        const Divider(),
                        _buildSummaryRow(
                            context.tr('Total'), totalSales.toStringAsFixed(2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Advanced Analytics tile (navigates to separate page)
                  GenericListTile(
                    leading: Icon(Icons.insights,
                        color: Theme.of(context).colorScheme.primary, size: 28),
                    titleWidget: Text(
                      context.tr('Advanced Analytics'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey.shade600),
                    onTap: () => context.push('/advanced_analytics'),
                  ),
                  // Resource Centre tile (navigates to separate page)
                  GenericListTile(
                    leading: Icon(Icons.folder,
                        color: Theme.of(context).colorScheme.primary, size: 28),
                    titleWidget: Text(
                      context.tr('Resource Centre'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey.shade600),
                    onTap: () => context.go('/resource_centre'),
                  ),
                ],
              );
            })
          ]
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
        children: [
          Text(context.tr('Daily')),
          Text(context.tr('Weekly')),
          Text(context.tr('Monthly'))
        ],
      ),
    );
  }
}
