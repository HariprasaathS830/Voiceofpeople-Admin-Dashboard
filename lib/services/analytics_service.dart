import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class AnalyticsService {
  final _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getHeatmapData() async {
    try {
      // 1. Fetch all candidate documents from Firestore users collection
      final snap = await _db
          .collection('users')
          .where('role', isEqualTo: 'general')
          .get();

      // 2. Extract regions/locations
      final List<String> locations = [];
      for (final doc in snap.docs) {
        final data = doc.data();
        final String? region = data['region'] as String?;
        if (region != null && region.trim().isNotEmpty) {
          locations.add(region.trim());
        }
      }

      if (locations.isEmpty) {
        return [];
      }

      // 3. Post to the backend geocoder endpoint
      final url = Uri.parse('http://localhost:3000/api/heatmap');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'locations': locations}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Backend error: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting heatmap data: $e');
      return [];
    }
  }

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