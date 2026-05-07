import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/revenue_cat_service.dart';
import '../../../providers/revenue_cat_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Offering? _offering;
  bool _isLoading = false;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    setState(() => _isLoading = true);
    try {
      final offering =
          await ref.read(revenueCatServiceProvider).getCurrentOffering();
      setState(() => _offering = offering);
    } catch (e) {
      debugPrint('Offering yüklenemedi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchase(Package package) async {
    setState(() => _isPurchasing = true);
    try {
      final success =
          await ref.read(revenueCatServiceProvider).purchase(package);
      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium\'a hoş geldin! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Satın alma başarısız: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    try {
      final success =
          await ref.read(revenueCatServiceProvider).restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Satın almalar geri yüklendi!' : 'Aktif abonelik bulunamadı.',
            ),
          ),
        );
        if (success) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kapat butonu
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // İkon
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Trakto Premium',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '3 abonelik limitini aş, tüm özelliklere eriş.',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Özellikler
                    _FeatureRow(
                      icon: Icons.all_inclusive_rounded,
                      title: 'Sınırsız abonelik',
                      subtitle: '3 limitini kaldır',
                      isDark: isDark,
                    ),
                    _FeatureRow(
                      icon: Icons.bar_chart_rounded,
                      title: 'Analiz ekranı',
                      subtitle: '"Değiyor mu?" raporu',
                      isDark: isDark,
                    ),
                    _FeatureRow(
                      icon: Icons.notifications_outlined,
                      title: 'Yenileme bildirimleri',
                      subtitle: '3 gün ve 1 gün önce uyarı',
                      isDark: isDark,
                    ),
                    _FeatureRow(
                      icon: Icons.download_outlined,
                      title: 'CSV export',
                      subtitle: 'Abonelikleri dışa aktar',
                      isDark: isDark,
                    ),
                    _FeatureRow(
                      icon: Icons.lock_outline_rounded,
                      title: 'PIN kilidi',
                      subtitle: 'Uygulama güvenliği',
                      isDark: isDark,
                    ),

                    const SizedBox(height: 32),

                    // Fiyat kartı
                    if (_offering != null) ...[
                      ..._offering!.availablePackages.map((package) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    package.storeProduct.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    package.storeProduct.priceString,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Yıllık ödeme · İstediğin zaman iptal et',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isPurchasing
                                      ? null
                                      : () => _purchase(package),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _isPurchasing
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : const Text(
                                          'Premium\'a Geç',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '\$19.99 / yıl',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Yıllık ödeme · İstediğin zaman iptal et',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Premium\'a Geç',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Restore
                    TextButton(
                      onPressed: _isPurchasing ? null : _restore,
                      child: Text(
                        'Satın almaları geri yükle',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
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
          Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}