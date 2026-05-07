import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/category_colors.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/revenue_cat_provider.dart';
import '../paywall/paywall_screen.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  ConsumerState<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState
    extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String _currency = 'TRY';
  BillingPeriod _billingPeriod = BillingPeriod.monthly;
  SubscriptionCategory _category = SubscriptionCategory.streaming;
  DateTime _renewalDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  final List<String> _currencies = ['TRY', 'USD', 'EUR', 'GBP'];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Premium kontrolü
    final limitReached = ref.read(subscriptionLimitReachedProvider);
    if (limitReached) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('Kullanıcı bulunamadı');

      final subscription = SubscriptionModel(
        id: const Uuid().v4(),
        userId: userId,
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        currency: _currency,
        billingPeriod: _billingPeriod,
        renewalDate: _renewalDate,
        category: _category,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await ref
          .read(subscriptionRepositoryProvider)
          .addSubscription(subscription);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonelik Ekle'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Kategori seçici (görsel)
            Text(
              'KATEGORİ',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 72,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: SubscriptionCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  final style = CategoryColors.of(cat);
                  final bg = isDark ? style.bgDark : style.bgLight;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? style.accent : bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? style.accent
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _categoryIcon(cat),
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : style.accent,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _categoryLabel(cat),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : style.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // İsim
            Text(
              'ABONELİK ADI',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Netflix, Spotify...',
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'İsim boş olamaz' : null,
            ),

            const SizedBox(height: 20),

            // Tutar + Para birimi
            Text(
              'TUTAR',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    decoration: const InputDecoration(hintText: '0.00'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Boş olamaz';
                      if (double.tryParse(v) == null) return 'Geçersiz';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    dropdownColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    decoration: const InputDecoration(),
                    items: _currencies
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _currency = v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Periyot
            Text(
              'YENİLEME PERİYODU',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: BillingPeriod.values.map((period) {
                final isSelected = _billingPeriod == period;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _billingPeriod = period),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: period == BillingPeriod.monthly ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        period == BillingPeriod.monthly ? 'Aylık' : 'Yıllık',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Yenileme tarihi
            Text(
              'YENİLEME TARİHİ',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _renewalDate,
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365 * 5)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: AppColors.primary,
                          surface: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) setState(() => _renewalDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_renewalDate.day}/${_renewalDate.month}/${_renewalDate.year}',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontSize: 15,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Kaydet
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Kaydet'),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.streaming:
        return Icons.play_circle_outline;
      case SubscriptionCategory.software:
        return Icons.code_outlined;
      case SubscriptionCategory.gaming:
        return Icons.sports_esports_outlined;
      case SubscriptionCategory.news:
        return Icons.newspaper_outlined;
      case SubscriptionCategory.fitness:
        return Icons.fitness_center_outlined;
      case SubscriptionCategory.education:
        return Icons.school_outlined;
      case SubscriptionCategory.cloud:
        return Icons.cloud_outlined;
      case SubscriptionCategory.other:
        return Icons.category_outlined;
    }
  }

  String _categoryLabel(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.streaming:
        return 'Stream';
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