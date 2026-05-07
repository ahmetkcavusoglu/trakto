import 'package:cloud_firestore/cloud_firestore.dart';

class UsageRecordModel {
  final String id;
  final String subscriptionId;
  final String userId;
  final int year;
  final int month;
  final bool used;
  final DateTime recordedAt;

  const UsageRecordModel({
    required this.id,
    required this.subscriptionId,
    required this.userId,
    required this.year,
    required this.month,
    required this.used,
    required this.recordedAt,
  });

  // Firestore'dan okuma
  factory UsageRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UsageRecordModel(
      id: doc.id,
      subscriptionId: data['subscriptionId'] ?? '',
      userId: data['userId'] ?? '',
      year: data['year'] ?? 0,
      month: data['month'] ?? 0,
      used: data['used'] ?? false,
      recordedAt: (data['recordedAt'] as Timestamp).toDate(),
    );
  }

  // Firestore'a yazma
  Map<String, dynamic> toFirestore() {
    return {
      'subscriptionId': subscriptionId,
      'userId': userId,
      'year': year,
      'month': month,
      'used': used,
      'recordedAt': Timestamp.fromDate(recordedAt),
    };
  }

  // Bu ay için benzersiz ID üret
  // Format: userId_subscriptionId_2026_05
  static String generateId(
      String userId, String subscriptionId, int year, int month) {
    return '${userId}_${subscriptionId}_${year}_$month';
  }

  UsageRecordModel copyWith({bool? used}) {
    return UsageRecordModel(
      id: id,
      subscriptionId: subscriptionId,
      userId: userId,
      year: year,
      month: month,
      used: used ?? this.used,
      recordedAt: DateTime.now(),
    );
  }
}