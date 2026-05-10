import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'data/services/notification_service.dart';
import 'data/services/pin_service.dart';
import 'presentation/screens/pin/pin_screen.dart';
import 'data/services/revenue_cat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init();
  await NotificationService().requestPermission();
  await RevenueCatService().init();

  runApp(
    const ProviderScope(
      child: SubscriptionAuditorApp(),
    ),
  );
}

class SubscriptionAuditorApp extends ConsumerWidget {
  const SubscriptionAuditorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Trakto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: authState.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text('Hata: $e')),
        ),
        data: (user) {
          if (user == null) return const LoginScreen();
          return const _PinGate();
        },
      ),
    );
  }
}

class _PinGate extends StatefulWidget {
  const _PinGate();

  @override
  State<_PinGate> createState() => _PinGateState();
}

class _PinGateState extends State<_PinGate> {
  final PinService _pinService = PinService();
  bool _pinVerified = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  Future<void> _checkPin() async {
    final pinEnabled = await _pinService.isPinEnabled();
    if (!pinEnabled) {
      setState(() {
        _pinVerified = true;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_pinVerified) {
      return PinScreen(
        mode: PinScreenMode.verify,
        onSuccess: () => setState(() => _pinVerified = true),
      );
    }
    return const HomeScreen();
  }
}