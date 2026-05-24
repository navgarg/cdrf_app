import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/models/transaction.dart';

class DailySummary {
  final DateTime date;
  final double sales;
  final double profit;

  DailySummary({required this.date, required this.sales, required this.profit});
}

final dashboardServiceProvider = Provider((ref) => DashboardService());

class DashboardService {
  List<DailySummary> getWeeklyData(
      List<Transaction> transactions, DateTime focusedDate) {
    final Map<DateTime, double> dailySales = {};
    final Map<DateTime, double> dailyProfits = {};

    for (final transaction in transactions) {
      if (transaction.transactionType != TransactionType.sale) continue;
      final date = DateTime(transaction.timestamp.year,
          transaction.timestamp.month, transaction.timestamp.day);
      dailySales.update(
          date, (value) => value + (transaction.price * transaction.quantity),
          ifAbsent: () => (transaction.price * transaction.quantity));
      dailyProfits.update(
          date,
          (value) =>
              value +
              ((transaction.price - transaction.cost) * transaction.quantity),
          ifAbsent: () =>
              ((transaction.price - transaction.cost) * transaction.quantity));
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
    return data;
  }

  List<DailySummary> getMonthlyData(
      List<Transaction> transactions, DateTime focusedDate) {
    final Map<DateTime, double> weeklySales = {};
    final Map<DateTime, double> weeklyProfits = {};

    for (final transaction in transactions) {
      if (transaction.transactionType != TransactionType.sale) continue;
      final date = DateTime(transaction.timestamp.year,
          transaction.timestamp.month, transaction.timestamp.day);
      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      weeklySales.update(startOfWeek,
          (value) => value + (transaction.price * transaction.quantity),
          ifAbsent: () => (transaction.price * transaction.quantity));
      weeklyProfits.update(
          startOfWeek,
          (value) =>
              value +
              ((transaction.price - transaction.cost) * transaction.quantity),
          ifAbsent: () =>
              ((transaction.price - transaction.cost) * transaction.quantity));
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
    return data;
  }

  List<DailySummary> getDailyData(
      List<Transaction> transactions, DateTime focusedDate) {
    debugPrint(transactions.toString());
    debugPrint('Calculating daily data for $focusedDate');
    debugPrint('Transactions count: ${transactions.length}');

    final Map<DateTime, double> intervalSales = {};
    final Map<DateTime, double> intervalProfits = {};

    final List<DateTime> intervals = [];
    for (int i = 0; i < 24; i += 4) {
      intervals.add(
          DateTime(focusedDate.year, focusedDate.month, focusedDate.day, i));
    }

    for (final transaction in transactions) {
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
          intervalSales.update(currentIntervalStart,
              (value) => value + (transaction.price * transaction.quantity),
              ifAbsent: () => (transaction.price * transaction.quantity));
          intervalProfits.update(
              currentIntervalStart,
              (value) =>
                  value +
                  ((transaction.price - transaction.cost) *
                      transaction.quantity),
              ifAbsent: () => ((transaction.price - transaction.cost) *
                  transaction.quantity));
        }
      }
    }

    final List<DailySummary> data = [];
    for (final intervalStart in intervals) {
      data.add(DailySummary(
        date: intervalStart,
        sales: intervalSales[intervalStart] ?? 0.0,
        profit: intervalProfits[intervalStart] ?? 0.0,
      ));
    }
    return data;
  }
}
