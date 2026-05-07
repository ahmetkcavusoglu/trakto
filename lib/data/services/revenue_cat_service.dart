import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const _apiKey = 'goog_PBWdGvfneGbLymJedQLRmGrDaNQ';
  static const _premiumEntitlement = 'premium';

  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(
      PurchasesConfiguration(_apiKey),
    );
  }

  // Kullanıcı premium mu?
  Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active
          .containsKey(_premiumEntitlement);
    } catch (e) {
      return false;
    }
  }

  // Premium stream — anlık güncelleme
  Stream<bool> get premiumStream async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      yield await isPremium();
    }
  }

  // Mevcut offering'i getir
  Future<Offering?> getCurrentOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current;
    } catch (e) {
      return null;
    }
  }

  // Satın al
  Future<bool> purchase(Package package) async {
    try {
      final customerInfo =
          await Purchases.purchasePackage(package);
      return customerInfo.entitlements.active
          .containsKey(_premiumEntitlement);
    } catch (e) {
      return false;
    }
  }

  // Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active
          .containsKey(_premiumEntitlement);
    } catch (e) {
      return false;
    }
  }

  // Kullanıcı ID'sini Firebase UID ile eşleştir
  Future<void> setUserId(String userId) async {
    await Purchases.logIn(userId);
  }
}