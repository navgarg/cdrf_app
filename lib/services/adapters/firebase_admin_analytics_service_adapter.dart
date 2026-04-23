import '../admin/admin_analytics_service.dart' as firebase;
import '../interfaces/i_admin_analytics_service.dart';

class FirebaseAdminAnalyticsServiceAdapter implements IAdminAnalyticsService {
  final firebase.AdminAnalyticsService _service =
      firebase.AdminAnalyticsService();

  @override
  Stream<AdminAnalyticsData> getAnalyticsStream() {
    return _service.getAnalyticsStream().map((d) {
      return AdminAnalyticsData(
        totalUsers: d.totalUsers,
        activeUsers: d.activeUsers,
        totalTransactions: d.totalTransactions,
        totalResources: d.totalResources,
        totalRevenue: d.totalRevenue,
      );
    });
  }

  @override
  Future<AdminAnalyticsData> fetchAnalyticsData() async {
    final d = await _service.fetchAnalyticsData();
    return AdminAnalyticsData(
      totalUsers: d.totalUsers,
      activeUsers: d.activeUsers,
      totalTransactions: d.totalTransactions,
      totalResources: d.totalResources,
      totalRevenue: d.totalRevenue,
    );
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() =>
      _service.getDashboardStats();
}
