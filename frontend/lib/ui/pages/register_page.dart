import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/bloc/auth/auth_bloc.dart';
import '../../logic/bloc/auth/auth_event.dart';
import '../../logic/bloc/auth/auth_state.dart';
import '../widgets/custom_primary_button.dart';
import '../widgets/custom_snackbar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTos = false;
  String? _apiErrorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    setState(() => _apiErrorMessage = null);
    if (!_acceptedTos) {
      CustomSnackbar.showError(context, 'Anda harus menyetujui Syarat & Ketentuan (TOS) terlebih dahulu');
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              _usernameController.text.trim(),
              _emailController.text.trim(),
              _passwordController.text,
            ),
          );
    }
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF94A3B8)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF153D77), width: 1.5),
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
                          errorBuilder: (ctx, err, st) => const Icon(
                              Icons.train,
                              size: 60,
                              color: Color(0xFF153D77)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Daftar untuk mulai hunting lokomotif',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Container(height: 1, color: const Color(0xFFE2E8F0)),
                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Daftar Akun Baru',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF153D77),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Lengkapi data di bawah untuk bergabung',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                    const SizedBox(height: 28),

                    // API Error Message
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
                            const Icon(Icons.error_outline,
                                color: Color(0xFFEF4444), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _apiErrorMessage!,
                                style: const TextStyle(
                                    color: Color(0xFFEF4444), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Username
                    _buildLabel('Username'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      decoration: _buildInputDecoration(
                        hintText: 'Masukkan username',
                        prefixIcon: Icons.person_outline,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Username tidak boleh kosong' : null,
                      onChanged: (_) {
                        if (_apiErrorMessage != null)
                          setState(() => _apiErrorMessage = null);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email
                    _buildLabel('Email'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration(
                        hintText: 'Masukkan email',
                        prefixIcon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Email tidak boleh kosong';
                        if (!value.contains('@'))
                          return 'Format email tidak valid';
                        return null;
                      },
                      onChanged: (_) {
                        if (_apiErrorMessage != null)
                          setState(() => _apiErrorMessage = null);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password
                    _buildLabel('Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _buildInputDecoration(
                        hintText: 'Masukkan password',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF94A3B8),
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) => value != null && value.length < 6
                          ? 'Password minimal 6 karakter'
                          : null,
                      onChanged: (_) {
                        if (_apiErrorMessage != null)
                          setState(() => _apiErrorMessage = null);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password
                    _buildLabel('Konfirmasi Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: _buildInputDecoration(
                        hintText: 'Masukkan ulang password',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF94A3B8),
                          ),
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text)
                          return 'Password tidak cocok';
                        return null;
                      },
                      onChanged: (_) {
                        if (_apiErrorMessage != null)
                          setState(() => _apiErrorMessage = null);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Terms of Service Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _acceptedTos,
                            activeColor: const Color(0xFF153D77),
                            onChanged: (val) {
                              setState(() => _acceptedTos = val ?? false);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF153D77).withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.description_outlined,
                                            color: Color(0xFF153D77),
                                            size: 36,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Syarat & Ketentuan',
                                          style: TextStyle(
                                            color: Color(0xFF1E293B),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                                          ),
                                          child: const SingleChildScrollView(
                                            child: Text(
                                              'Dengan mendaftar sebagai kontributor (Railfans) di aplikasi RailSensus, Anda menyetujui bahwa:\n\n'
                                              '1. Seluruh aktivitas pengambilan foto dan data sensus kereta/lokomotif wajib dilakukan di area publik yang aman.\n\n'
                                              '2. DILARANG KERAS mengambil data atau memasuki area terbatas (restricted area) milik perusahaan operator kereta api (PT KAI) tanpa izin resmi.\n\n'
                                              '3. Keamanan dan keselamatan pribadi sepenuhnya menjadi tanggung jawab Anda.\n\n'
                                              '4. Pelanggaran terhadap aturan ini dapat mengakibatkan pemblokiran akun dan tindakan lain sesuai hukum yang berlaku.',
                                              style: TextStyle(
                                                height: 1.6,
                                                color: Color(0xFF64748B),
                                                fontSize: 14,
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                              backgroundColor: const Color(0xFF153D77),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              setState(() => _acceptedTos = true);
                                            },
                                            child: const Text(
                                              'Saya Setuju',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                fontFamily: 'Plus Jakarta Sans',
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
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontFamily: 'Plus Jakarta Sans'),
                                children: [
                                  TextSpan(text: 'Saya telah membaca dan menyetujui '),
                                  TextSpan(
                                    text: 'Syarat & Ketentuan (TOS)',
                                    style: TextStyle(color: Color(0xFF153D77), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                  ),
                                  TextSpan(text: ' mengenai keselamatan berburu foto kereta.'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Register Button
                    CustomPrimaryButton(
                      text: 'Daftar Sekarang',
                      isLoading: state is AuthLoading,
                      onPressed: _onRegister,
                    ),
                    const SizedBox(height: 12),

                    // Divider with "atau"
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(color: Color(0xFFE2E8F0))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('atau',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 13)),
                        ),
                        const Expanded(
                            child: Divider(color: Color(0xFFE2E8F0))),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Login Link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(text: 'Sudah punya akun? '),
                              TextSpan(
                                text: 'Masuk di sini',
                                style: TextStyle(
                                    color: Color(0xFFFF9428),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF153D77),
      ),
    );
  }
}
