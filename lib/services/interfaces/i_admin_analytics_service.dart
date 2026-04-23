class AdminAnalyticsData {
  final int totalUsers;
  final int activeUsers;
  final int totalTransactions;
  final int totalResources;
  final double totalRevenue;

  AdminAnalyticsData({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalTransactions,
    required this.totalResources,
    required this.totalRevenue,
  });
}

abstract class IAdminAnalyticsService {
  Stream<AdminAnalyticsData> getAnalyticsStream();

  Future<AdminAnalyticsData> fetchAnalyticsData();

  Future<Map<String, dynamic>> getDashboardStats();
}
