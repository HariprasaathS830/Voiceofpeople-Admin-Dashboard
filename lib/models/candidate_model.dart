import 'package:cloud_firestore/cloud_firestore.dart';

enum CandidateStatus { registered, verified, active, inactive }

class CandidateModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final CandidateStatus status;
  final DateTime registeredAt;
  final DateTime? lastActive;
  final String? assignedVolunteerId;
  final String? region;
  final Map<String, dynamic> metadata;

  CandidateModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.registeredAt,
    this.lastActive,
    this.assignedVolunteerId,
    this.region,
    this.metadata = const {},
  });

  factory CandidateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CandidateModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      status: CandidateStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'registered'),
        orElse: () => CandidateStatus.registered,
      ),
      registeredAt:
          (data['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
      assignedVolunteerId: data['assignedVolunteerId'],
      region: data['region'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }
}