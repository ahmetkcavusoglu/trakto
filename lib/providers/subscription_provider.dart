import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/subscription_model.dart';
import '../data/repositories/subscription_repository.dart';
import 'auth_provider.dart';
import 'revenue_cat_provider.dart';

// Repository provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

// Abonelik listesi stream provider
final subscriptionsProvider = StreamProvider<List<SubscriptionModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();

  return ref
      .watch(subscriptionRepositoryProvider)
      .getSubscriptions(userId);
});

// Aylık toplam tutar
final monthlyTotalProvider = Provider<double>((ref) {
  final subscriptions = ref.watch(subscriptionsProvider).valueOrNull ?? [];
  return subscriptions
      .where((s) => s.isActive)
      .fold(0.0, (total, s) {
        if (s.billingPeriod == BillingPeriod.yearly) {
          return total + (s.amount / 12); // Yıllığı aylığa çevir
        }
        return total + s.amount;
      });
});

// Yıllık toplam tutar
final yearlyTotalProvider = Provider<double>((ref) {
  final subscriptions = ref.watch(subscriptionsProvider).valueOrNull ?? [];
  return subscriptions
      .where((s) => s.isActive)
      .fold(0.0, (total, s) {
        if (s.billingPeriod == BillingPeriod.monthly) {
          return total + (s.amount * 12); // Aylığı yıllığa çevir
        }
        return total + s.amount;
      });
});

// 3 abonelik limitine ulaşıldı mı?
final subscriptionLimitReachedProvider = Provider<bool>((ref) {
  final subscriptions = ref.watch(subscriptionsProvider).valueOrNull ?? [];
  final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
  if (isPremium) return false;
  return subscriptions.length >= 3;
});