import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/models/transaction.dart';
import 'package:nariudyam/services/api/transaction_service.dart';
import 'package:flutter/foundation.dart';

class DailySummary {
  final DateTime date;
  final double sales;
  final double profit;

  DailySummary({required this.date, required this.sales, required this.profit});
}

final dashboardServiceProvider = Provider((ref) => DashboardService(ref));

class DashboardService {
  final Ref _ref;

  DashboardService(this._ref);
  Stream<List<DailySummary>> getWeeklyData(DateTime focusedDate) {
    return _ref.watch(allTransactionsStreamProvider).when(
          data: (transactions) {
            if (transactions.isEmpty) {
              debugPrint(
                  'No transactions found — returning empty weekly data.');
              return Stream.value(<DailySummary>[]);
            }
            final Map<DateTime, double> dailySales = {};
            final Map<DateTime, double> dailyProfits = {};
            for (var transaction in transactions) {
              if (transaction.transactionType != TransactionType.sale) continue;
              final date = DateTime(transaction.timestamp.year,
                  transaction.timestamp.month, transaction.timestamp.day);
              final revenue = transaction.price * transaction.quantity;
              final profit =
                  (transaction.price - transaction.cost) * transaction.quantity;
              dailySales.update(date, (value) => value + revenue,
                  ifAbsent: () => revenue);
              dailyProfits.update(date, (value) => value + profit,
                  ifAbsent: () => profit);
            }

            final List<DailySummary> data = [];
            for (int i = -3; i <= 3; i++) {
              final date =
                  DateTime(focusedDate.year, focusedDate.month, focusedDate.day)
                      .add(Duration(days: i));
              data.add(DailySummary(
                  date: date,
                  sales: dailySales[date] ?? 0.0,
                  profit: dailyProfits[date] ?? 0.0));
            }
            return Stream.value(data);
          },
          loading: () => Stream.value([]), // Return empty list while loading
          error: (err, stack) {
            debugPrint(
                'Error fetching transactions in getWeeklyData: $err\n$stack');
            return Stream.value([]); // Return empty list on error
          },
        );
  }

  Stream<List<DailySummary>> getMonthlyData(DateTime focusedDate) {
    return _ref.watch(allTransactionsStreamProvider).when(
          data: (transactions) {
            if (transactions.isEmpty) {
              debugPrint(
                  'No transactions found — returning empty monthly data.');
              return Stream.value(<DailySummary>[]);
            }
            final Map<DateTime, double> weeklySales = {};
            final Map<DateTime, double> weeklyProfits = {};
            for (var transaction in transactions) {
              if (transaction.transactionType != TransactionType.sale) continue;
              final date = DateTime(transaction.timestamp.year,
                  transaction.timestamp.month, transaction.timestamp.day);
              final startOfWeek =
                  date.subtract(Duration(days: date.weekday - 1));
              final revenue = transaction.price * transaction.quantity;
              final profit =
                  (transaction.price - transaction.cost) * transaction.quantity;
              weeklySales.update(startOfWeek, (value) => value + revenue,
                  ifAbsent: () => revenue);
              weeklyProfits.update(startOfWeek, (value) => value + profit,
                  ifAbsent: () => profit);
            }

            final List<DailySummary> data = [];
            for (int i = -2; i <= 2; i++) {
              final date = focusedDate
                  .subtract(Duration(days: focusedDate.weekday - 1))
                  .add(Duration(days: 7 * i));
              data.add(DailySummary(
                  date: date,
                  sales: weeklySales[date] ?? 0.0,
                  profit: weeklyProfits[date] ?? 0.0));
            }
            return Stream.value(data);
          },
          loading: () => Stream.value([]), // Return empty list while loading
          error: (err, stack) {
            debugPrint(
                'Error fetching transactions in getMonthlyData: $err\n$stack');
            return Stream.value([]); // Return empty list on error
          },
        );
  }

  Stream<List<DailySummary>> getDailyData(DateTime focusedDate) {
    return _ref.watch(allTransactionsStreamProvider).when(
          data: (transactions) {
            if (transactions.isEmpty) {
              debugPrint('No transactions found — returning empty daily data.');
              return Stream.value(<DailySummary>[]);
            }
            debugPrint(transactions.toString());
            debugPrint('Calculating daily data for $focusedDate');
            debugPrint('Transactions count: ${transactions.length}');
            final Map<DateTime, double> intervalSales = {};
            final Map<DateTime, double> intervalProfits = {};

            final List<DateTime> intervals = [];
            for (int i = 0; i < 24; i += 4) {
              intervals.add(DateTime(
                  focusedDate.year, focusedDate.month, focusedDate.day, i));
            }

            for (var transaction in transactions) {
              if (transaction.transactionType != TransactionType.sale) continue;
              final transactionDateTime = transaction.timestamp;
              if (transactionDateTime.year == focusedDate.year &&
                  transactionDateTime.month == focusedDate.month &&
                  transactionDateTime.day == focusedDate.day) {
                DateTime? currentIntervalStart;
                for (int i = 0; i < intervals.length; i++) {
                  if (transactionDateTime.isAfter(intervals[i]) ||
                      transactionDateTime.isAtSameMomentAs(intervals[i])) {
                    if (i + 1 < intervals.length) {
                      if (transactionDateTime.isBefore(intervals[i + 1])) {
                        currentIntervalStart = intervals[i];
                        break;
                      }
                    } else {
                      currentIntervalStart = intervals[i];
                      break;
                    }
                  }
                }

                if (currentIntervalStart != null) {
                  final revenue = transaction.price * transaction.quantity;
                  final profit = (transaction.price - transaction.cost) *
                      transaction.quantity;
                  intervalSales.update(
                      currentIntervalStart, (value) => value + revenue,
                      ifAbsent: () => revenue);
                  intervalProfits.update(
                      currentIntervalStart, (value) => value + profit,
                      ifAbsent: () => profit);
                }
              }
            }

            final List<DailySummary> data = [];
            for (var intervalStart in intervals) {
              data.add(DailySummary(
                date: intervalStart,
                sales: intervalSales[intervalStart] ?? 0.0,
                profit: intervalProfits[intervalStart] ?? 0.0,
              ));
            }
            return Stream.value(data);
          },
          loading: () => Stream.value([]), // Return empty list while loading
          error: (err, stack) {
            debugPrint(
                'Error fetching transactions in getDailyData: $err\n$stack');
            return Stream.value([]); // Return empty list on error
          },
        );
  }
}
