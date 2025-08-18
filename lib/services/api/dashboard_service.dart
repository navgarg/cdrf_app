import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/services/api/transaction_service.dart';

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
  Stream<List<DailySummary>> getDailyData(DateTime focusedDate) {
    return _ref.read(transactionServiceProvider).streamTransactions().map((transactions) {
      final Map<DateTime, double> dailySales = {};
      final Map<DateTime, double> dailyProfits = {};
      for (var transaction in transactions) {
        final date = DateTime(transaction.timestamp.year, transaction.timestamp.month, transaction.timestamp.day);
        dailySales.update(date, (value) => value + transaction.price, ifAbsent: () => transaction.price);
        dailyProfits.update(date, (value) => value + (transaction.price - transaction.cost), ifAbsent: () => (transaction.price - transaction.cost));
      }

      final List<DailySummary> data = [];
      for (int i = -3; i <= 3; i++) {
        final date = DateTime(focusedDate.year, focusedDate.month, focusedDate.day).add(Duration(days: i));
        data.add(DailySummary(date: date, sales: dailySales[date] ?? 0.0, profit: dailyProfits[date] ?? 0.0));
      }
      return data;
    });
  }

  Stream<List<DailySummary>> getWeeklyData(DateTime focusedDate) {
    return _ref.read(transactionServiceProvider).streamTransactions().map((transactions) {
      final Map<DateTime, double> weeklySales = {};
      final Map<DateTime, double> weeklyProfits = {};
      for (var transaction in transactions) {
        final date = DateTime(transaction.timestamp.year, transaction.timestamp.month, transaction.timestamp.day);
        final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        weeklySales.update(startOfWeek, (value) => value + transaction.price, ifAbsent: () => transaction.price);
        weeklyProfits.update(startOfWeek, (value) => value + (transaction.price - transaction.cost), ifAbsent: () => (transaction.price - transaction.cost));
      }

      final List<DailySummary> data = [];
      for (int i = -2; i <= 2; i++) {
        final date = focusedDate.subtract(Duration(days: focusedDate.weekday - 1)).add(Duration(days: 7 * i));
        data.add(DailySummary(date: date, sales: weeklySales[date] ?? 0.0, profit: weeklyProfits[date] ?? 0.0));
      }
      return data;
    });
  }

  Stream<List<DailySummary>> getMonthlyData(DateTime focusedDate) {
    return _ref.read(transactionServiceProvider).streamTransactions().map((transactions) {
      final Map<DateTime, double> monthlySales = {};
      final Map<DateTime, double> monthlyProfits = {};
      for (var transaction in transactions) {
        final date = DateTime(transaction.timestamp.year, transaction.timestamp.month, 1);
        monthlySales.update(date, (value) => value + transaction.price, ifAbsent: () => transaction.price);
        monthlyProfits.update(date, (value) => value + (transaction.price - transaction.cost), ifAbsent: () => (transaction.price - transaction.cost));
      }

      final List<DailySummary> data = [];
      for (int i = -2; i <= 2; i++) {
        final date = DateTime(focusedDate.year, focusedDate.month + i, 1);
        data.add(DailySummary(date: date, sales: monthlySales[date] ?? 0.0, profit: monthlyProfits[date] ?? 0.0));
      }
      return data;
    });
  }
}
