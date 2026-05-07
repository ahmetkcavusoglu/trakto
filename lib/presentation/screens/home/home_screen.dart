import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/subscription_card.dart';
import '../subscription/add_subscription_screen.dart';
import '../analysis/analysis_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

    final List<Widget> _screens = const [
        _HomeTab(),
        AnalysisScreen(),
        SettingsScreen(),
    ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Orta buton — abonelik ekle
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddSubscriptionScreen(),
              ),
            );
            return;
          }
          setState(() => _currentIndex = index > 2 ? index - 1 : index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: '',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    final monthlyTotal = ref.watch(monthlyTotalProvider);
    final yearlyTotal = ref.watch(yearlyTotalProvider);
    final authService = ref.watch(authServiceProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    return SafeArea(
      child: Column(
        children: [
          // Üst bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Merhaba, ${user?.displayName?.split(' ').first ?? 'Kullanıcı'}',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentMonth(),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _IconButton(
                      icon: isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      isDark: isDark,
                      onTap: () =>
                          ref.read(themeProvider.notifier).toggle(),
                    ),
                    const SizedBox(width: 8),
                    _IconButton(
                      icon: Icons.logout_outlined,
                      isDark: isDark,
                      onTap: () => authService.signOut(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Hero kart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AYLIK TOPLAM',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₺${monthlyTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _HeroSubItem(
                        label: 'Yıllık',
                        value: '₺${yearlyTotal.toStringAsFixed(0)}',
                      ),
                      const SizedBox(width: 10),
                      _HeroSubItem(
                        label: 'Aktif',
                        value:
                            '${subscriptionsAsync.valueOrNull?.length ?? 0} abone',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Liste başlığı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ABONELİKLER',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${subscriptionsAsync.valueOrNull?.length ?? 0} adet',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Liste
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 56,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz abonelik yok',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Aşağıdaki + butonuna bas',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    return SubscriptionCard(
                      subscription: subscriptions[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _currentMonth() {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}

class _HeroSubItem extends StatelessWidget {
  final String label;
  final String value;

  const _HeroSubItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}