import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/api_provider.dart';
import '../../logic/bloc/auth/auth_bloc.dart';
import '../../logic/bloc/auth/auth_state.dart';
import '../../logic/bloc/admin_master/admin_master_bloc.dart';
import '../../logic/bloc/admin_master/admin_master_event.dart';
import '../../logic/bloc/admin_master/admin_master_state.dart';
import '../widgets/logout_dialog.dart';

class AdminDashboardPage extends StatefulWidget {
  final VoidCallback? onNavigateToReports;
  const AdminDashboardPage({super.key, this.onNavigateToReports});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminMasterBloc>().add(const LoadAdminStatsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Header / App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/RailSensus_Logo.png',
                      height: 36,
                      errorBuilder: (ctx, err, st) => Row(
                        children: const [
                          Icon(Icons.train_rounded, color: Color(0xFF153D77), size: 28),
                          SizedBox(width: 8),
                          Text(
                            'RailSensus',
                            style: TextStyle(
                              color: Color(0xFF153D77),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthAuthenticated && state.user != null) {
                          final user = state.user!;
                          return Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFF153D77).withOpacity(0.1),
                                  backgroundImage: user.fotoProfil != null
                                      ? CachedNetworkImageProvider(
                                          '${ApiProvider.baseUrl.replaceAll('/api', '')}${user.fotoProfil}')
                                      : null,
                                  child: user.fotoProfil == null
                                      ? Text(
                                          user.username.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF153D77),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                                  onPressed: () {
                                    LogoutDialog.show(context);
                                  },
                                  splashRadius: 20,
                                ),
                              ),
                            ],
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                            onPressed: () {
                              LogoutDialog.show(context);
                            },
                            splashRadius: 20,
                          ),
                        );
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
                    String name = 'Admin';
                    if (state is AuthAuthenticated && state.user != null) {
                      name = state.user!.username;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $name! 👑',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF153D77),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Selamat datang di Dasbor Administrator.',
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
              const SizedBox(height: 32),

              // Bento UI: Statistik & Aksi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: BlocBuilder<AdminMasterBloc, AdminMasterState>(
                  buildWhen: (previous, current) => current is AdminStatsLoaded,
                  builder: (context, state) {
                    int totalUsers = 0;
                    int totalSensus = 0;
                    int totalLaporan = 0;

                    if (state is AdminStatsLoaded) {
                      totalUsers = state.stats['totalUsers'] ?? 0;
                      totalSensus = state.stats['totalSensus'] ?? 0;
                      totalLaporan = state.stats['totalLaporan'] ?? 0;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Row: 3 cards inline
                        Row(
                          children: [
                            Expanded(
                              child: _buildBentoStatCard(
                                title: 'Sensus',
                                value: totalSensus.toString(),
                                icon: Icons.assignment_turned_in,
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildBentoStatCard(
                                title: 'Laporan',
                                value: totalLaporan.toString(),
                                icon: Icons.playlist_add_check_circle,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildBentoStatCard(
                                title: 'Users',
                                value: totalUsers.toString(),
                                icon: Icons.group,
                                color: const Color(0xFFEC4899),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Aksi Cepat (Input Baru)
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildBentoActionCard(
                                title: 'Input Sensus Baru',
                                icon: Icons.post_add,
                                color: const Color(0xFF10B981),
                                onTap: () => context.push('/sensus/form'),
                                isLarge: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildBentoActionCard(
                                title: 'Loko Baru',
                                icon: Icons.add_circle_outline,
                                color: const Color(0xFF3B82F6),
                                onTap: () => context.push('/lokomotif/form'),
                                isLarge: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Manajemen Laporan
                        Row(
                          children: [
                            Expanded(
                              child: _buildBentoActionCard(
                                title: 'Manajemen Laporan',
                                icon: Icons.playlist_add_check_circle,
                                color: const Color(0xFFF59E0B),
                                onTap: () {
                                  if (widget.onNavigateToReports != null) {
                                    widget.onNavigateToReports!();
                                  } else {
                                    context.push('/admin/reports');
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Kelola Master Data
                        Row(
                          children: [
                            Expanded(
                              child: _buildBentoActionCard(
                                title: 'Master Kereta',
                                icon: Icons.directions_railway,
                                color: const Color(0xFF8B5CF6),
                                onTap: () =>
                                    context.push('/admin/master-kereta'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildBentoActionCard(
                                title: 'Master Depo',
                                icon: Icons.business,
                                color: const Color(0xFF6366F1),
                                onTap: () => context.push('/admin/master-depo'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildBentoActionCard(
                                title: 'Master Users',
                                icon: Icons.manage_accounts,
                                color: const Color(0xFFEC4899),
                                onTap: () =>
                                    context.push('/admin/master-users'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 130, // Compact height for 3 in a row
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isLarge ? 120 : 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: isLarge ? 32 : 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isLarge ? 14 : 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
