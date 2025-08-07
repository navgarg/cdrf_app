import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailySummary {
  final DateTime date;
  final double sales;
  final double profit;

  DailySummary({required this.date, required this.sales, required this.profit});
}

final dashboardServiceProvider = Provider((ref) => DashboardService());

class DashboardService {
  // Dummy data for demonstration
  List<DailySummary> getDailyData() {
    return [
      DailySummary(date: DateTime(2023, 10, 26), sales: 100, profit: 20),
      DailySummary(date: DateTime(2023, 10, 27), sales: 120, profit: 25),
      DailySummary(date: DateTime(2023, 10, 28), sales: 90, profit: 15),
      DailySummary(date: DateTime(2023, 10, 29), sales: 150, profit: 30),
      DailySummary(date: DateTime(2023, 10, 30), sales: 110, profit: 22),
      DailySummary(date: DateTime(2023, 10, 31), sales: 130, profit: 28),
      DailySummary(date: DateTime(2023, 11, 1), sales: 160, profit: 35),
    ];
  }

  List<DailySummary> getWeeklyData() {
    final dailyData = getDailyData();
    double totalSales = 0;
    double totalProfit = 0;
    for (var summary in dailyData) {
      totalSales += summary.sales;
      totalProfit += summary.profit;
    }
    return [
      DailySummary(date: DateTime.now(), sales: totalSales, profit: totalProfit)
    ];
  }

  List<DailySummary> getMonthlyData() {
    final dailyData = getDailyData();
    double totalSales = 0;
    double totalProfit = 0;
    for (var summary in dailyData) {
      totalSales += summary.sales;
      totalProfit += summary.profit;
    }
    return [
      DailySummary(date: DateTime.now(), sales: totalSales, profit: totalProfit)
    ];
  }
}
