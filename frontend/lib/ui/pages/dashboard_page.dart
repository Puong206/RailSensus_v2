import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/bloc/auth/auth_bloc.dart';
import '../../logic/bloc/auth/auth_event.dart';
import '../../logic/bloc/auth/auth_state.dart';
import '../../logic/bloc/sensus/sensus_bloc.dart';
import '../../logic/bloc/sensus/sensus_event.dart';
import '../../logic/bloc/sensus/sensus_state.dart';
import '../widgets/sensus_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<SensusBloc>().add(SensusFetchRequested(page: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/RailSensus_Logo.png',
                        height: 32,
                        errorBuilder: (ctx, err, st) =>
                            const Icon(Icons.train, color: Color(0xFF153D77))),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                    ),
                  ],
                ),
              ),

              // Welcome Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    String name = 'User';
                    if (state is AuthAuthenticated && state.user != null) {
                      name = state.user!.username;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $name! 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF153D77),
                          ),
                        ),
                        const Text(
                          'Siap hunting kereta hari ini?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Fitur Utama
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Fitur Utama',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF153D77),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        context,
                        title: 'Sarana Lokomotif',
                        subtitle: 'Data armada',
                        icon: Icons.train,
                        color: const Color(0xFF153D77),
                        onTap: () => context.go(
                            '/main'), // Handled by bottom nav normally, but could push to list specifically if needed
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFeatureCard(
                        context,
                        title: 'Sensus KA',
                        subtitle: 'Input pergerakan',
                        icon: Icons.assignment,
                        color: const Color(0xFFFF9428),
                        onTap: () =>
                            context.go('/main'), // Handled by bottom nav
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sensus Terbaru
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sensus Terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF153D77),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {}, // Handled by bottom nav, switch tab
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9428),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Horizontal List of Sensus
              SizedBox(
                height: 270,
                child: BlocBuilder<SensusBloc, SensusState>(
                  builder: (context, state) {
                    if (state is SensusLoading && state.isFirstFetch) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF153D77)));
                    } else if (state is SensusError) {
                      return Center(child: Text(state.message));
                    } else if (state is SensusLoaded ||
                        (state is SensusLoading && !state.isFirstFetch)) {
                      final sensusList = (state is SensusLoaded)
                          ? state.sensus
                          : (state as SensusLoading).oldSensus;

                      if (sensusList.isEmpty) {
                        return const Center(
                            child: Text('Belum ada sensus',
                                style: TextStyle(color: Colors.grey)));
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        itemCount: sensusList.length > 5
                            ? 5
                            : sensusList.length, // Show up to 5 on dashboard
                        itemBuilder: (context, index) {
                          return SensusCard(sensus: sensusList[index]);
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color == const Color(0xFF153D77)
                    ? const Color(0xFF153D77)
                    : const Color(0xFF153D77),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
