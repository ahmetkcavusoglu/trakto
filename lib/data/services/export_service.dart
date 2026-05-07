import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/subscription_model.dart';

class ExportService {
  Future<void> exportToCsv(List<SubscriptionModel> subscriptions) async {
    // Başlık satırı
    final rows = <List<dynamic>>[
      [
        'İsim',
        'Tutar',
        'Para Birimi',
        'Periyot',
        'Kategori',
        'Yenileme Tarihi',
        'Aktif',
        'Notlar',
      ],
    ];

    // Veri satırları
    for (final sub in subscriptions) {
      rows.add([
        sub.name,
        sub.amount.toStringAsFixed(2),
        sub.currency,
        sub.billingPeriod == BillingPeriod.monthly ? 'Aylık' : 'Yıllık',
        _categoryLabel(sub.category),
        '${sub.renewalDate.day}/${sub.renewalDate.month}/${sub.renewalDate.year}',
        sub.isActive ? 'Evet' : 'Hayır',
        sub.notes ?? '',
      ]);
    }

    // CSV string üret
    final csv = const ListToCsvConverter().convert(rows);

    // Dosyaya yaz
    final directory = await getTemporaryDirectory();
    final now = DateTime.now();
    final fileName =
        'abonelikler_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csv);

    // Paylaş
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Abonelik Listesi — Subscription Auditor',
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