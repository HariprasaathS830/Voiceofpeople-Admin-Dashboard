import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDashboardStats() async {
    final results = await Future.wait([
      _db.collection('volunteers').count().get(),
      _db.collection('volunteers')
          .where('status', isEqualTo: 'approved')
          .count()
          .get(),
      _db.collection('volunteers')
          .where('status', isEqualTo: 'pending')
          .count()
          .get(),
      _db.collection('users').count().get(),
      _db.collection('users')
          .where('role', isEqualTo: 'general')
          .count()
          .get(),
    ]);

    return {
      'totalVolunteers': results[0].count ?? 0,
      'activeVolunteers': results[1].count ?? 0,
      'pendingApprovals': results[2].count ?? 0,
      'totalUsers': results[3].count ?? 0,
      'generalUsers': results[4].count ?? 0,
    };
  }

  /// Returns last 7 days registration counts
  Future<List<Map<String, dynamic>>> getRegistrationTrend() async {
    final now = DateTime.now();
    final trend = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      final snap = await _db
          .collection('users')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end))
          .count()
          .get();
      trend.add({'date': start, 'count': snap.count ?? 0});
    }
    return trend;
  }
}