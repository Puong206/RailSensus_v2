import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/bloc/auth/auth_bloc.dart';
import '../../logic/bloc/auth/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Additional background animations
  late AnimationController _bgController;
  late Animation<double> _bgScaleAnimation;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Animasi utama (logo, teks, fade in)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Animasi background yang bernafas terus menerus (loop)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _bgScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOutSine),
    );

    // Efek elastis (bouncy) pada logo utama
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.8, curve: Curves.elasticOut)),
    );

    // Efek perlahan muncul dari transparan ke solid
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    // Efek meluncur (sliding) dari bawah ke atas untuk bagian branding
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _navigate(BuildContext context, AuthState state) async {
    if (_isNavigating) return;
    _isNavigating = true;

    // Paksa splash screen tampil selama 3.5 detik agar animasi selesai & bisa dinikmati
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!context.mounted) return;

    if (state is AuthAuthenticated) {
      context.go('/main');
    } else if (state is AuthUnauthenticated || state is AuthError) {
      context.go('/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Hanya memicu navigasi apabila state auth sudah dipastikan statusnya
        if (state is AuthAuthenticated || state is AuthUnauthenticated || state is AuthError) {
          _navigate(context, state);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Subtle Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF4F7FB), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            
            // Decorative shapes moving slowly (breathing effect)
            AnimatedBuilder(
              animation: _bgScaleAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -150,
                      right: -100,
                      child: Transform.scale(
                        scale: _bgScaleAnimation.value,
                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF153D77).withValues(alpha: 0.04),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -100,
                      left: -150,
                      child: Transform.scale(
                        scale: _bgScaleAnimation.value,
                        child: Container(
                          width: 350,
                          height: 350,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFF9428).withValues(alpha: 0.04),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),

            // Main Content
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo with soft shadow
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF153D77).withValues(alpha: 0.15),
                                  blurRadius: 50,
                                  spreadRadius: -10,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/RailSensus_Logo.png',
                              width: 220,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.train_rounded, size: 100, color: Color(0xFF153D77)),
                            ),
                          ),
                          const SizedBox(height: 60),
                          
                          // Custom Loader
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF153D77)),
                              backgroundColor: const Color(0xFF153D77).withValues(alpha: 0.1),
                              strokeWidth: 3.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Branding
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'RAILSENSUS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF153D77),
                                letterSpacing: 8,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Sistem Informasi Pendataan Sarana',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Versi 1.0.0',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
