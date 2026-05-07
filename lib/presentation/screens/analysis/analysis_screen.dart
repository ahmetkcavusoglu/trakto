import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/category_colors.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/usage_provider.dart';
import '../../../providers/auth_provider.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscriptionsAsync = ref.watch(subscriptionsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Analiz',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Hangi abonelikler gerçekten değiyor?',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: subscriptionsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
                error: (e, _) => Center(child: Text('Hata: $e')),
                data: (subscriptions) {
                  if (subscriptions.isEmpty) {
                    return Center(
                      child: Text(
                        'Henüz abonelik yok',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: subscriptions.length,
                    itemBuilder: (context, index) {
                      return _AnalysisCard(
                          subscription: subscriptions[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCard extends ConsumerWidget {
  final SubscriptionModel subscription;

  const _AnalysisCard({required this.subscription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryStyle = CategoryColors.of(subscription.category);
    final historyAsync = ref.watch(usageHistoryProvider(subscription.id));
    final userId = ref.watch(currentUserIdProvider);

    final iconBg = isDark ? categoryStyle.bgDark : categoryStyle.bgLight;
    final iconColor = categoryStyle.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    subscription.name[0].toUpperCase(),
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.name,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${subscription.currency} ${subscription.amount.toStringAsFixed(0)} / '
                      '${subscription.billingPeriod == BillingPeriod.monthly ? 'ay' : 'yıl'}',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Karar badge
              historyAsync.when(
                loading: () => const SizedBox(),
                error: (e, _) => const SizedBox(),
                data: (history) =>
                    _VerdictBadge(history: history, isDark: isDark),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Son 6 ay kullanım grafiği
          historyAsync.when(
            loading: () => const SizedBox(height: 32),
            error: (e, _) => const SizedBox(),
            data: (history) => _UsageGrid(
              history: history,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerdictBadge extends StatelessWidget {
  final List history;
  final bool isDark;

  const _VerdictBadge({required this.history, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final usedCount = history.where((r) => r.used == true).length;
    final total = history.length;

    if (total < 3) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Yeni',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Son 3 ay hiç kullanılmadıysa uyarı
    final last3 = history.take(3).toList();
    final last3Used = last3.where((r) => r.used == true).length;

    if (last3Used == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.badgeRedDarkBg : AppColors.badgeRedLightBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'İptal et',
          style: TextStyle(
            color: isDark
                ? AppColors.badgeRedDarkText
                : AppColors.badgeRedLightText,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final ratio = usedCount / total;
    if (ratio >= 0.7) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.badgeGreenDarkBg
              : AppColors.badgeGreenLightBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Değiyor ✓',
          style: TextStyle(
            color: isDark
                ? AppColors.badgeGreenDarkText
                : AppColors.badgeGreenLightText,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.badgeAmberDarkBg : AppColors.badgeAmberLightBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Gözden geçir',
        style: TextStyle(
          color: isDark
              ? AppColors.badgeAmberDarkText
              : AppColors.badgeAmberLightText,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _UsageGrid extends StatelessWidget {
  final List history;
  final bool isDark;

  const _UsageGrid({required this.history, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];

    // Son 6 ayı oluştur
    final now = DateTime.now();
    final last6 = List.generate(6, (i) {
      final date = DateTime(now.year, now.month - (5 - i), 1);
      return date;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son 6 ay',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: last6.map((date) {
            // Bu ay için kayıt var mı?
            final record = history.where((r) =>
                r.year == date.year && r.month == date.month).firstOrNull;

            Color dotColor;
            if (record == null) {
              dotColor = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
            } else if (record.used == true) {
              dotColor = isDark
                  ? AppColors.badgeGreenDarkText
                  : AppColors.badgeGreenLightText;
            } else {
              dotColor = isDark
                  ? AppColors.badgeRedDarkText
                  : AppColors.badgeRedLightText;
            }

            final isCurrentMonth =
                date.year == now.year && date.month == now.month;

            return Expanded(
              child: Column(
                children: [
                  Container(
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: dotColor,
                      borderRadius: BorderRadius.circular(6),
                      border: isCurrentMonth
                          ? Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    months[date.month - 1],
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}