import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/bloc/auth/auth_bloc.dart';
import '../../logic/bloc/auth/auth_event.dart';
import '../../logic/bloc/auth/auth_state.dart';
import '../widgets/custom_primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _apiErrorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    setState(() => _apiErrorMessage = null);
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          _usernameController.text.trim(),
          _passwordController.text,
        ),
      );
    }
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool hasError = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: hasError ? const Color(0xFFEF4444) : const Color(0xFF94A3B8)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: hasError ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: hasError ? const Color(0xFFEF4444) : const Color(0xFF153D77), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() {
              _apiErrorMessage = state.message.replaceAll('Exception: ', '');
            });
          } else if (state is AuthAuthenticated) {
            context.go('/main');
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/RailSensus_Logo.png',
                          height: 60,
                          errorBuilder: (ctx, err, st) => const Icon(Icons.train, size: 60, color: Color(0xFF153D77)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Masuk untuk melanjutkan hunting lokomotif',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Container(height: 1, color: const Color(0xFFE2E8F0)),
                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Selamat Datang!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF153D77),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Login dengan username Anda',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                    const SizedBox(height: 28),

                    // Username Label
                    const Text(
                      'Username',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF153D77)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      decoration: _buildInputDecoration(
                        hintText: 'Masukkan username',
                        prefixIcon: Icons.person_outline,
                        hasError: _apiErrorMessage != null,
                      ),
                      validator: (value) => value!.isEmpty ? 'Username tidak boleh kosong' : null,
                      onChanged: (_) {
                        if (_apiErrorMessage != null) setState(() => _apiErrorMessage = null);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Label
                    const Text(
                      'Password',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF153D77)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _buildInputDecoration(
                        hintText: 'Masukkan password',
                        prefixIcon: Icons.lock_outline,
                        hasError: _apiErrorMessage != null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF94A3B8),
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Password tidak boleh kosong' : null,
                      onChanged: (_) {
                        if (_apiErrorMessage != null) setState(() => _apiErrorMessage = null);
                      },
                    ),
                    const SizedBox(height: 32),

                    // API Error Message (shown below title)
                    if (_apiErrorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _apiErrorMessage!,
                                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Login Button
                    CustomPrimaryButton(
                      text: 'Masuk',
                      isLoading: state is AuthLoading,
                      onPressed: _onLogin,
                    ),
                    const SizedBox(height: 24),

                    // Divider with "atau"
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('atau', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Register Link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/register'),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(text: 'Belum punya akun? '),
                              TextSpan(
                                text: 'Daftar sekarang',
                                style: TextStyle(color: Color(0xFFFF9428), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
