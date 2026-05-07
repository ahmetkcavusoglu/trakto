import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/pin_service.dart';
import '../../../data/services/export_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/theme_provider.dart';
import '../pin/pin_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final PinService _pinService = PinService();
  final ExportService _exportService = ExportService();
  bool _pinEnabled = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadPinStatus();
  }

  Future<void> _loadPinStatus() async {
    final enabled = await _pinService.isPinEnabled();
    setState(() => _pinEnabled = enabled);
  }

  Future<void> _togglePin() async {
    if (_pinEnabled) {
      // PIN'i kaldır
      await _pinService.removePin();
      setState(() => _pinEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN kaldırıldı')),
        );
      }
    } else {
      // PIN kur
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PinScreen(
            mode: PinScreenMode.setup,
            onSuccess: () {
              Navigator.pop(context);
              setState(() => _pinEnabled = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN oluşturuldu')),
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      final subscriptions =
          ref.read(subscriptionsProvider).valueOrNull ?? [];
      if (subscriptions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dışa aktarılacak abonelik yok')),
          );
        }
        return;
      }
      await _exportService.exportToCsv(subscriptions);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Ayarlar',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Görünüm
                  _SectionTitle(label: 'GÖRÜNÜM', isDark: isDark),
                  _SettingsTile(
                    icon: isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    title: 'Tema',
                    subtitle: themeMode == ThemeMode.dark
                        ? 'Koyu mod'
                        : 'Açık mod',
                    isDark: isDark,
                    trailing: Switch(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (_) =>
                          ref.read(themeProvider.notifier).toggle(),
                      activeColor: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Güvenlik
                  _SectionTitle(label: 'GÜVENLİK', isDark: isDark),
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'PIN Kilidi',
                    subtitle: _pinEnabled ? 'Aktif' : 'Kapalı',
                    isDark: isDark,
                    trailing: Switch(
                      value: _pinEnabled,
                      onChanged: (_) => _togglePin(),
                      activeColor: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Veri
                  _SectionTitle(label: 'VERİ', isDark: isDark),
                  _SettingsTile(
                    icon: Icons.download_outlined,
                    title: 'CSV Dışa Aktar',
                    subtitle: 'Abonelikleri CSV olarak indir',
                    isDark: isDark,
                    trailing: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            Icons.chevron_right_rounded,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                    onTap: _isExporting ? null : _exportCsv,
                  ),

                  const SizedBox(height: 20),

                  // Hesap
                  _SectionTitle(label: 'HESAP', isDark: isDark),
                  _SettingsTile(
                    icon: Icons.logout_outlined,
                    title: 'Çıkış Yap',
                    subtitle: ref
                            .watch(authStateProvider)
                            .valueOrNull
                            ?.email ??
                        '',
                    isDark: isDark,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                    onTap: () => authService.signOut(),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionTitle({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive
                    ? (isDark
                        ? AppColors.badgeRedDarkBg
                        : AppColors.badgeRedLightBg)
                    : (isDark
                        ? AppColors.darkSurface2
                        : AppColors.lightSurface2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDestructive
                    ? (isDark
                        ? AppColors.badgeRedDarkText
                        : AppColors.badgeRedLightText)
                    : AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive
                          ? (isDark
                              ? AppColors.badgeRedDarkText
                              : AppColors.badgeRedLightText)
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
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
            trailing,
          ],
        ),
      ),
    );
  }
}