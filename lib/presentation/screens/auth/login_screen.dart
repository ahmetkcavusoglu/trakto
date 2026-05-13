import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: $e'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).registerWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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

    // iOS sistem renkleri — light/dark ayrı
    final primaryBlue = isDark
        ? const Color(0xFF0A84FF)
        : const Color(0xFF007AFF);
    final textPrimary = isDark ? Colors.white : Colors.black;
    final textSecondary = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF6E6E73);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 56),

              // Logo — gerçek uygulama ikonu
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), // iOS squircle
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Uygulama adı
              Center(
                child: Text(
                  'Trakto',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Tagline
              Center(
                child: Text(
                  'Track subscriptions, cut waste.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Email alanı
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: GoogleFonts.poppins(
                    color: textSecondary,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.mail_outline_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Şifre alanı
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: GoogleFonts.poppins(
                    color: textSecondary,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Sign In butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 12),

              // Create Account butonu
              OutlinedButton(
                onPressed: _isLoading ? null : _register,
                child: const Text('Create Account'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}