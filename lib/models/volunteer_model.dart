import 'package:cloud_firestore/cloud_firestore.dart';

enum VolunteerStatus { pending, approved, rejected, suspended }

class VolunteerModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final VolunteerStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? assignedZone;
  final int totalActivities;
  final String? profileImageUrl;

  VolunteerModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.assignedZone,
    this.totalActivities = 0,
    this.profileImageUrl,
  });

  factory VolunteerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VolunteerModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      status: VolunteerStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => VolunteerStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      assignedZone: data['assignedZone'],
      totalActivities: data['totalActivities'] ?? 0,
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
        'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
        'assignedZone': assignedZone,
        'totalActivities': totalActivities,
        'profileImageUrl': profileImageUrl,
      };
}