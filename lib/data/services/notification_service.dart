import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../data/models/subscription_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

    Future<void> requestPermission() async {
        final androidImpl = _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await androidImpl?.requestNotificationsPermission();
    }

  // Tek abonelik için bildirimleri planla
  Future<void> scheduleRenewalNotifications(
      SubscriptionModel subscription) async {
    // Önce bu aboneliğin eski bildirimlerini iptal et
    await cancelSubscriptionNotifications(subscription.id);

    final renewalDate = subscription.renewalDate;
    final now = DateTime.now();

    // 3 gün önce
    final threeDaysBefore = renewalDate.subtract(const Duration(days: 3));
    if (threeDaysBefore.isAfter(now)) {
      await _scheduleNotification(
        id: _notificationId(subscription.id, 3),
        title: '${subscription.name} yenileniyor',
        body: '3 gün sonra ₺${subscription.amount.toStringAsFixed(0)} çekilecek.',
        scheduledDate: threeDaysBefore,
      );
    }

    // 1 gün önce
    final oneDayBefore = renewalDate.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(now)) {
      await _scheduleNotification(
        id: _notificationId(subscription.id, 1),
        title: '${subscription.name} yarın yenileniyor!',
        body: 'Yarın ₺${subscription.amount.toStringAsFixed(0)} çekilecek.',
        scheduledDate: oneDayBefore,
      );
    }
  }

  // Tüm abonelikler için bildirimleri planla
  Future<void> scheduleAllNotifications(
      List<SubscriptionModel> subscriptions) async {
    for (final sub in subscriptions) {
      await scheduleRenewalNotifications(sub);
    }
  }

  // Bir aboneliğin bildirimlerini iptal et
  Future<void> cancelSubscriptionNotifications(String subscriptionId) async {
    await _plugin.cancel(_notificationId(subscriptionId, 3));
    await _plugin.cancel(_notificationId(subscriptionId, 1));
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'renewal_channel',
          'Yenileme Bildirimleri',
          channelDescription: 'Abonelik yenileme hatırlatmaları',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Abonelik ID'sinden benzersiz bildirim ID'si üret
  int _notificationId(String subscriptionId, int daysBefore) {
    return '${subscriptionId}_$daysBefore'.hashCode.abs() % 100000;
  }
}