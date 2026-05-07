import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_model.dart';
import '../services/notification_service.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notifications = NotificationService();

  CollectionReference _userSubscriptions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions');
  }

  Stream<List<SubscriptionModel>> getSubscriptions(String userId) {
    return _userSubscriptions(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubscriptionModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addSubscription(SubscriptionModel subscription) async {
    await _userSubscriptions(subscription.userId)
        .doc(subscription.id)
        .set(subscription.toFirestore());

    // Bildirim planla
    await _notifications.scheduleRenewalNotifications(subscription);
  }

  Future<void> updateSubscription(SubscriptionModel subscription) async {
    await _userSubscriptions(subscription.userId)
        .doc(subscription.id)
        .update(subscription.toFirestore());

    // Bildirimleri güncelle
    await _notifications.scheduleRenewalNotifications(subscription);
  }

  Future<void> deleteSubscription(
      String userId, String subscriptionId) async {
    await _userSubscriptions(userId).doc(subscriptionId).delete();

    // Bildirimleri iptal et
    await _notifications.cancelSubscriptionNotifications(subscriptionId);
  }
}