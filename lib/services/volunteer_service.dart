import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/volunteer_model.dart';

class VolunteerService {
  final _db = FirebaseFirestore.instance;
  final _col = FirebaseFirestore.instance.collection('volunteers');

  Stream<List<VolunteerModel>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(VolunteerModel.fromFirestore).toList());

  Stream<List<VolunteerModel>> watchByStatus(VolunteerStatus status) => _col
      .where('status', isEqualTo: status.name)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(VolunteerModel.fromFirestore).toList());

  Future<void> updateStatus(String uid, VolunteerStatus status) =>
      _col.doc(uid).update({
        'status': status.name,
        if (status == VolunteerStatus.approved)
          'approvedAt': Timestamp.now(),
      });

  Future<void> assignZone(String uid, String zone) =>
      _col.doc(uid).update({'assignedZone': zone});

  Future<void> deleteVolunteer(String uid) => _col.doc(uid).delete();

  Future<Map<String, int>> getStatusCounts() async {
    final counts = <String, int>{};
    for (final s in VolunteerStatus.values) {
      final snap =
          await _col.where('status', isEqualTo: s.name).count().get();
      counts[s.name] = snap.count ?? 0;
    }
    return counts;
  }
}