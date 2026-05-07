import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/category_colors.dart';
import '../../data/models/subscription_model.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/usage_provider.dart';
import '../../providers/auth_provider.dart';

class SubscriptionCard extends ConsumerWidget {
  final SubscriptionModel subscription;

  const SubscriptionCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryStyle = CategoryColors.of(subscription.category);
    final repository = ref.watch(subscriptionRepositoryProvider);
    final usageAsync = ref.watch(monthlyUsageProvider(subscription.id));

    final iconBg = isDark ? categoryStyle.bgDark : categoryStyle.bgLight;
    final iconColor = categoryStyle.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Kategori ikonu
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                subscription.name[0].toUpperCase(),
                style: TextStyle(
                  color: iconColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Bilgiler
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
                const SizedBox(height: 2),
                Text(
                  '${_categoryLabel(subscription.category)} · '
                  '${subscription.billingPeriod == BillingPeriod.monthly ? 'Aylık' : 'Yıllık'}',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),

                // Kullanım badge — tıklanabilir
                usageAsync.when(
                  loading: () => const SizedBox(height: 20),
                  error: (e, _) => const SizedBox(),
                  data: (usage) => _UsageBadge(
                    subscription: subscription,
                    isUsed: usage?.used,
                    onTap: () async {
                      final userId =
                          ref.read(currentUserIdProvider);
                      if (userId == null) return;
                      final now = DateTime.now();
                      final currentlyUsed = usage?.used ?? false;
                      await ref
                          .read(usageRepositoryProvider)
                          .setUsage(
                            userId: userId,
                            subscriptionId: subscription.id,
                            year: now.year,
                            month: now.month,
                            used: !currentlyUsed,
                          );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Tutar + silme
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${subscription.currency} ${subscription.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subscription.billingPeriod == BillingPeriod.monthly
                    ? '/ay'
                    : '/yıl',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  await repository.deleteSubscription(
                    subscription.userId,
                    subscription.id,
                  );
                },
                child: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryLabel(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.streaming:
        return 'Streaming';
      case SubscriptionCategory.software:
        return 'Yazılım';
      case SubscriptionCategory.gaming:
        return 'Oyun';
      case SubscriptionCategory.news:
        return 'Haber';
      case SubscriptionCategory.fitness:
        return 'Fitness';
      case SubscriptionCategory.education:
        return 'Eğitim';
      case SubscriptionCategory.cloud:
        return 'Bulut';
      case SubscriptionCategory.other:
        return 'Diğer';
    }
  }
}

class _UsageBadge extends StatelessWidget {
  final SubscriptionModel subscription;
  final bool? isUsed;
  final VoidCallback onTap;

  const _UsageBadge({
    required this.subscription,
    required this.isUsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color textColor;
    String label;
    IconData icon;

    if (isUsed == null) {
      // Henüz işaretlenmemiş
      bg = isDark ? AppColors.badgeAmberDarkBg : AppColors.badgeAmberLightBg;
      textColor = isDark
          ? AppColors.badgeAmberDarkText
          : AppColors.badgeAmberLightText;
      label = 'Bu ay kullandım mı?';
      icon = Icons.help_outline_rounded;
    } else if (isUsed == true) {
      bg = isDark ? AppColors.badgeGreenDarkBg : AppColors.badgeGreenLightBg;
      textColor = isDark
          ? AppColors.badgeGreenDarkText
          : AppColors.badgeGreenLightText;
      label = 'Kullandım ✓';
      icon = Icons.check_circle_outline_rounded;
    } else {
      bg = isDark ? AppColors.badgeRedDarkBg : AppColors.badgeRedLightBg;
      textColor =
          isDark ? AppColors.badgeRedDarkText : AppColors.badgeRedLightText;
      label = 'Kullanmadım';
      icon = Icons.cancel_outlined;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}