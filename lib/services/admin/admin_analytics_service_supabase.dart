import 'package:supabase_flutter/supabase_flutter.dart';

import '../interfaces/i_admin_analytics_service.dart';

class AdminAnalyticsServiceSupabase implements IAdminAnalyticsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Stream<AdminAnalyticsData> getAnalyticsStream() async* {
    yield await fetchAnalyticsData();
    await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
      yield await fetchAnalyticsData();
    }
  }

  @override
  Future<AdminAnalyticsData> fetchAnalyticsData() async {
    try {
      final results = await Future.wait([
        _getTotalUsers(),
        _getActiveUsers(),
        _getTotalTransactionsAndRevenue(),
        _getTotalResources(),
      ]);

      final totalUsers = results[0] as int;
      final activeUsers = results[1] as int;
      final transactionData = results[2] as Map<String, dynamic>;
      final totalResources = results[3] as int;

      return AdminAnalyticsData(
        totalUsers: totalUsers,
        activeUsers: activeUsers,
        totalTransactions: transactionData['count'] as int,
        totalResources: totalResources,
        totalRevenue: transactionData['revenue'] as double,
      );
    } catch (_) {
      return AdminAnalyticsData(
        totalUsers: 0,
        activeUsers: 0,
        totalTransactions: 0,
        totalResources: 0,
        totalRevenue: 0.0,
      );
    }
  }

  Future<int> _getTotalUsers() async {
    try {
      final rows = await _supabase.from('users').select('uid');
      return (rows as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _getActiveUsers() async {
    try {
      final sevenDaysAgo =
          DateTime.now().subtract(const Duration(days: 7)).toUtc();
      final rows = await _supabase
          .from('transactions')
          .select('user_id, timestamp')
          .gte('timestamp', sevenDaysAgo.toIso8601String());

      final ids = <String>{};
      for (final row in (rows as List)) {
        final m = row as Map<String, dynamic>;
        final id = m['user_id']?.toString();
        if (id != null) ids.add(id);
      }
      return ids.length;
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> _getTotalTransactionsAndRevenue() async {
    try {
      final rows = await _supabase
          .from('transactions')
          .select('price, quantity, transaction_type');

      int count = 0;
      double revenue = 0.0;

      for (final row in (rows as List)) {
        count++;
        final m = row as Map<String, dynamic>;
        final type = m['transaction_type']?.toString();
        final price = (m['price'] as num?)?.toDouble() ?? 0.0;
        final quantity = (m['quantity'] as num?)?.toDouble() ?? 0.0;
        if (type == 'sale') {
          revenue += price * quantity;
        }
      }

      return {
        'count': count,
        'revenue': revenue,
      };
    } catch (_) {
      return {
        'count': 0,
        'revenue': 0.0,
      };
    }
  }

  Future<int> _getTotalResources() async {
    try {
      final rows = await _supabase.from('resource_center').select('id');
      return (rows as List).length;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final results = await Future.wait([
        _getTotalUsers(),
        _getTotalResources(),
        _getTotalTransactionsAndRevenue(),
      ]);

      final totalUsers = results[0] as int;
      final totalResources = results[1] as int;
      final transactionData = results[2] as Map<String, dynamic>;

      return {
        'totalUsers': totalUsers,
        'totalResources': totalResources,
        'totalRevenue': transactionData['revenue'] as double,
        'activeToday': 0,
      };
    } catch (_) {
      return {
        'totalUsers': 0,
        'totalResources': 0,
        'totalRevenue': 0.0,
        'activeToday': 0,
      };
    }
  }
}
