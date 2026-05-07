import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/usage_repository.dart';
import '../data/models/usage_record_model.dart';
import 'auth_provider.dart';

// Repository provider
final usageRepositoryProvider = Provider<UsageRepository>((ref) {
  return UsageRepository();
});

// Bu ayki kullanım durumu — her abonelik için ayrı provider
final monthlyUsageProvider = StreamProvider.family<UsageRecordModel?,
    String>((ref, subscriptionId) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();

  final now = DateTime.now();
  return ref.watch(usageRepositoryProvider).getMonthlyUsage(
        userId: userId,
        subscriptionId: subscriptionId,
        year: now.year,
        month: now.month,
      );
});

// Kullanım geçmişi — abonelik ID'sine göre
final usageHistoryProvider =
    StreamProvider.family<List<UsageRecordModel>, String>(
        (ref, subscriptionId) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();

  return ref.watch(usageRepositoryProvider).getUsageHistory(
        userId: userId,
        subscriptionId: subscriptionId,
      );
});