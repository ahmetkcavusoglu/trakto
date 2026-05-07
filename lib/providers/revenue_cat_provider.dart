import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/revenue_cat_service.dart';
import 'auth_provider.dart';

// RevenueCat servis provider
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

// Premium durumu stream provider
final premiumProvider = StreamProvider<bool>((ref) {
  return ref.watch(revenueCatServiceProvider).premiumStream;
});

// Premium durumu anlık kontrol
final isPremiumProvider = FutureProvider<bool>((ref) async {
  return ref.watch(revenueCatServiceProvider).isPremium();
});