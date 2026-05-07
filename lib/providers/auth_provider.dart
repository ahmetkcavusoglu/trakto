import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart';

// AuthService provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Kullanıcı durumu stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Mevcut kullanıcı ID'si
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});