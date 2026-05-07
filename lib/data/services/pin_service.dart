import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  static const _pinKey = 'app_pin';
  static const _pinEnabledKey = 'pin_enabled';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // PIN ayarlanmış mı?
  Future<bool> isPinEnabled() async {
    final value = await _storage.read(key: _pinEnabledKey);
    return value == 'true';
  }

  // PIN kaydet
  Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    await _storage.write(key: _pinEnabledKey, value: 'true');
  }

  // PIN'i kaldır
  Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
    await _storage.write(key: _pinEnabledKey, value: 'false');
  }

  // PIN doğrula
  Future<bool> verifyPin(String pin) async {
    final storedPin = await _storage.read(key: _pinKey);
    return storedPin == pin;
  }

  // Kayıtlı PIN'i getir (sadece iç kullanım)
  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }
}