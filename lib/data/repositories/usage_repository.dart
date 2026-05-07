import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usage_record_model.dart';

class UsageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _usageCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('usage_records');
  }

  // Bu ayki kaydı getir (tek kayıt)
  Stream<UsageRecordModel?> getMonthlyUsage({
    required String userId,
    required String subscriptionId,
    required int year,
    required int month,
  }) {
    final id = UsageRecordModel.generateId(
        userId, subscriptionId, year, month);
    return _usageCollection(userId)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists
            ? UsageRecordModel.fromFirestore(doc)
            : null);
  }

  // Bir aboneliğin tüm kullanım geçmişi
  Stream<List<UsageRecordModel>> getUsageHistory({
    required String userId,
    required String subscriptionId,
  }) {
    return _usageCollection(userId)
        .where('subscriptionId', isEqualTo: subscriptionId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UsageRecordModel.fromFirestore(doc))
            .toList());
  }

  // Kullanım işaretle / güncelle
  Future<void> setUsage({
    required String userId,
    required String subscriptionId,
    required int year,
    required int month,
    required bool used,
  }) async {
    final id = UsageRecordModel.generateId(
        userId, subscriptionId, year, month);
    final record = UsageRecordModel(
      id: id,
      subscriptionId: subscriptionId,
      userId: userId,
      year: year,
      month: month,
      used: used,
      recordedAt: DateTime.now(),
    );
    await _usageCollection(userId)
        .doc(id)
        .set(record.toFirestore());
  }

  // Kaç aydır kullanılmadı (analiz için)
  Future<int> getUnusedMonthCount({
    required String userId,
    required String subscriptionId,
  }) async {
    final now = DateTime.now();
    int unusedCount = 0;

    for (int i = 1; i <= 6; i++) {
      // Son 6 ayı kontrol et
      final date = DateTime(now.year, now.month - i, 1);
      final id = UsageRecordModel.generateId(
          userId, subscriptionId, date.year, date.month);
      final doc = await _usageCollection(userId).doc(id).get();

      if (!doc.exists) break; // Kayıt yoksa dur
      final record = UsageRecordModel.fromFirestore(doc);
      if (record.used) break; // Kullanıldıysa dur
      unusedCount++;
    }

    return unusedCount;
  }
}