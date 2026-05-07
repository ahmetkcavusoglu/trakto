import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionCategory {
  streaming,
  software,
  gaming,
  news,
  fitness,
  education,
  cloud,
  other,
}

enum BillingPeriod {
  monthly,
  yearly,
}

class SubscriptionModel {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String currency;
  final BillingPeriod billingPeriod;
  final DateTime renewalDate;
  final SubscriptionCategory category;
  final String? iconUrl;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.currency,
    required this.billingPeriod,
    required this.renewalDate,
    required this.category,
    this.iconUrl,
    this.notes,
    this.isActive = true,
    required this.createdAt,
  });

  // Firestore'dan okuma
  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] ?? 'TRY',
      billingPeriod: BillingPeriod.values.byName(data['billingPeriod']),
      renewalDate: (data['renewalDate'] as Timestamp).toDate(),
      category: SubscriptionCategory.values.byName(data['category']),
      iconUrl: data['iconUrl'],
      notes: data['notes'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestore'a yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'amount': amount,
      'currency': currency,
      'billingPeriod': billingPeriod.name,
      'renewalDate': Timestamp.fromDate(renewalDate),
      'category': category.name,
      'iconUrl': iconUrl,
      'notes': notes,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Güncelleme için copyWith
  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? currency,
    BillingPeriod? billingPeriod,
    DateTime? renewalDate,
    SubscriptionCategory? category,
    String? iconUrl,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      renewalDate: renewalDate ?? this.renewalDate,
      category: category ?? this.category,
      iconUrl: iconUrl ?? this.iconUrl,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}