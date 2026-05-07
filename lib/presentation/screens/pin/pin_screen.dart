import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/pin_service.dart';

enum PinScreenMode { setup, verify }

class PinScreen extends StatefulWidget {
  final PinScreenMode mode;
  final VoidCallback onSuccess;

  const PinScreen({
    super.key,
    required this.mode,
    required this.onSuccess,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final PinService _pinService = PinService();
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _errorMessage = '';

  void _onKeyTap(String key) {
    if (key == 'del') {
      setState(() {
        if (_isConfirming) {
          if (_confirmPin.isNotEmpty) {
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          }
        } else {
          if (_pin.isNotEmpty) {
            _pin = _pin.substring(0, _pin.length - 1);
          }
        }
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
      if (_isConfirming) {
        if (_confirmPin.length < 4) _confirmPin += key;
      } else {
        if (_pin.length < 4) _pin += key;
      }
    });

    // 4 hane dolunca işlem yap
    if (widget.mode == PinScreenMode.setup) {
      _handleSetup();
    } else {
      _handleVerify();
    }
  }

  void _handleSetup() {
    if (!_isConfirming && _pin.length == 4) {
      setState(() => _isConfirming = true);
      return;
    }
    if (_isConfirming && _confirmPin.length == 4) {
      if (_pin == _confirmPin) {
        _pinService.setPin(_pin);
        widget.onSuccess();
      } else {
        setState(() {
          _confirmPin = '';
          _errorMessage = 'PIN\'ler eşleşmedi, tekrar dene';
        });
      }
    }
  }

  Future<void> _handleVerify() async {
    if (_pin.length == 4) {
      final isValid = await _pinService.verifyPin(_pin);
      if (isValid) {
        widget.onSuccess();
      } else {
        setState(() {
          _pin = '';
          _errorMessage = 'Yanlış PIN';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPin = _isConfirming ? _confirmPin : _pin;

    String title;
    if (widget.mode == PinScreenMode.verify) {
      title = 'PIN\'ini gir';
    } else if (_isConfirming) {
      title = 'PIN\'i onayla';
    } else {
      title = 'PIN oluştur';
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kilit ikonu
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                title,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              // Hata mesajı
              Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),

              // PIN noktaları
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < currentPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkSurface2
                              : AppColors.lightSurface2),
                      border: Border.all(
                        color: filled
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),

              // Numpad
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                childAspectRatio: 1.4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  ...['1', '2', '3', '4', '5', '6', '7', '8', '9']
                      .map((k) => _KeyButton(
                            label: k,
                            onTap: () => _onKeyTap(k),
                            isDark: isDark,
                          )),
                  const SizedBox(),
                  _KeyButton(
                    label: '0',
                    onTap: () => _onKeyTap('0'),
                    isDark: isDark,
                  ),
                  _KeyButton(
                    label: '⌫',
                    onTap: () => _onKeyTap('del'),
                    isDark: isDark,
                    isDelete: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDelete;

  const _KeyButton({
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDelete
                  ? (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)
                  : (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary),
              fontSize: isDelete ? 20 : 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}