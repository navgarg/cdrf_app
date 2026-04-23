import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminAnalyticsServiceProvider =
    Provider((ref) => AdminAnalyticsService());

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

class AdminAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream that provides real-time analytics data
  Stream<AdminAnalyticsData> getAnalyticsStream() async* {
    // Emit initial data immediately
    yield await fetchAnalyticsData();

    // Then update periodically
    await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
      yield await fetchAnalyticsData();
    }
  }

  /// Fetch all analytics data at once
  Future<AdminAnalyticsData> fetchAnalyticsData() async {
    try {
      // Fetch all data in parallel
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
    } catch (e) {
      // Return zeros on error
      return AdminAnalyticsData(
        totalUsers: 0,
        activeUsers: 0,
        totalTransactions: 0,
        totalResources: 0,
        totalRevenue: 0.0,
      );
    }
  }

  /// Get total number of registered users
  Future<int> _getTotalUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get number of active users in the last 7 days
  /// A user is considered active if they have transactions in the last 7 days
  Future<int> _getActiveUsers() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final usersSnapshot = await _firestore.collection('users').get();

      int activeCount = 0;

      for (final userDoc in usersSnapshot.docs) {
        // Check if user has any transactions in the last 7 days
        final transactionsSnapshot = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('businesses')
            .doc(userDoc.id)
            .collection('transactions')
            .where('timestamp', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
            .limit(1)
            .get();

        if (transactionsSnapshot.docs.isNotEmpty) {
          activeCount++;
        }
      }

      return activeCount;
    } catch (e) {
      return 0;
    }
  }

  /// Get total transactions count and total revenue across all users
  Future<Map<String, dynamic>> _getTotalTransactionsAndRevenue() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();

      int totalTransactions = 0;
      double totalRevenue = 0.0;

      for (final userDoc in usersSnapshot.docs) {
        // Get all transactions for this user
        final transactionsSnapshot = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('businesses')
            .doc(userDoc.id)
            .collection('transactions')
            .get();

        totalTransactions += transactionsSnapshot.docs.length;

        // Sum up revenue (price * quantity for each transaction)
        for (final transDoc in transactionsSnapshot.docs) {
          final data = transDoc.data();
          final price = (data['price'] ?? 0.0) as num;
          final quantity = (data['quantity'] ?? 0) as num;
          final transactionType = data['transactionType'] as String?;

          // Only count 'sale' transactions as revenue
          if (transactionType == 'sale') {
            totalRevenue += (price * quantity).toDouble();
          }
        }
      }

      return {
        'count': totalTransactions,
        'revenue': totalRevenue,
      };
    } catch (e) {
      return {
        'count': 0,
        'revenue': 0.0,
      };
    }
  }

  /// Get total number of resources uploaded
  Future<int> _getTotalResources() async {
    try {
      final snapshot = await _firestore.collection('resource_center').get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get analytics for dashboard (simplified version)
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
        'activeToday': 0, // This would require tracking user activity
      };
    } catch (e) {
      return {
        'totalUsers': 0,
        'totalResources': 0,
        'totalRevenue': 0.0,
        'activeToday': 0,
      };
    }
  }
}
