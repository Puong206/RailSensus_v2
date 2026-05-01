import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_primary_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Make status bar transparent so content renders behind it
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Get the safe area paddings
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Content Section with manual top padding for status bar
          Padding(
            padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: 'Selamat ',
                        style: TextStyle(color: Color(0xFF153D77)),
                      ),
                      TextSpan(
                        text: 'Datang',
                        style: TextStyle(color: Color(0xFFFF9428)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.6,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                    children: [
                      TextSpan(text: 'Gabung dengan '),
                      TextSpan(
                        text: 'komunitas',
                        style: TextStyle(
                          color: Color(0xFFFF9428),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' untuk berbagi\n'),
                      TextSpan(
                        text: 'data sensus lokomotif',
                        style: TextStyle(
                          color: Color(0xFFFF9428),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' yang akurat. '),
                      TextSpan(
                        text: 'Hunting',
                        style: TextStyle(
                          color: Color(0xFFFF9428),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: '\njadi '),
                      TextSpan(
                        text: 'lebih mudah',
                        style: TextStyle(
                          color: Color(0xFFFF9428),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: CustomPrimaryButton(
                        text: 'Login',
                        onPressed: () => context.push('/login'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: CustomPrimaryButton(
                        text: 'Register',
                        isOutlined: true,
                        onPressed: () => context.push('/register'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Train Image - fills remaining space, edge to edge
          Expanded(
            child: ClipRect(
              child: Image.asset(
                'assets/images/Landing_Image.png',
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF153D77).withValues(alpha: 0.1),
                  child: const Center(
                    child: Icon(Icons.train, size: 80, color: Color(0xFF153D77)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
