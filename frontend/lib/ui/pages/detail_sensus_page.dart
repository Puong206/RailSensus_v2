import '../widgets/custom_snackbar.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:railsensus/data/repositories/sensus_repository.dart';
import '../../data/repositories/laporan_hapus_sensus_repository.dart';
import 'package:go_router/go_router.dart';
import '../../logic/bloc/sensus/sensus_bloc.dart';
import '../../logic/bloc/sensus/sensus_event.dart';
import '../../logic/bloc/sensus/sensus_state.dart';
import '../../data/models/sensus_model.dart';
import '../../logic/bloc/auth/auth_bloc.dart';
import '../../logic/bloc/auth/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../widgets/edit_sensus_dialog.dart';

class DetailSensusPage extends StatefulWidget {
  final String id;
  const DetailSensusPage({super.key, required this.id});

  @override
  State<DetailSensusPage> createState() => _DetailSensusPageState();
}

class _DetailSensusPageState extends State<DetailSensusPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    context.read<SensusBloc>().add(SensusDetailRequested(int.parse(widget.id)));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─── Color Constants ─────────────────────────────────────
  static const _navy = Color(0xFF153D77);
  static const _navyDark = Color(0xFF0F2D5A);
  static const _orange = Color(0xFFFF9428);
  static const _green = Color(0xFF22C55E);
  static const _red = Color(0xFFEF4444);
  static const _slate50 = Color(0xFFF8FAFC);
  static const _slate100 = Color(0xFFF1F5F9);
  static const _slate200 = Color(0xFFE2E8F0);
  static const _slate400 = Color(0xFF94A3B8);
  static const _slate500 = Color(0xFF64748B);
  static const _slate800 = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slate50,
      body: BlocConsumer<SensusBloc, SensusState>(
        listener: (context, state) {
          if (state is SensusDetailLoaded) {
            _animController.forward(from: 0);
          }
        },
        builder: (context, state) {
          if (state is SensusLoading && state.isFirstFetch) {
            return const Center(
                child: CircularProgressIndicator(color: _navy));
          }
          if (state is SensusError) {
            return _buildErrorState(state.message);
          }
          if (state is SensusDetailLoaded) {
            return _buildDetailContent(context, state.sensus);
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.train_outlined, size: 64, color: _slate400),
                const SizedBox(height: 16),
                Text('Data tidak ditemukan',
                    style: TextStyle(color: _slate500, fontSize: 16)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<SensusBloc, SensusState>(
        builder: (context, state) {
          if (state is SensusDetailLoaded) {
            return _buildBottomActionBar(context, state.sensus);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: _red, size: 48),
            ),
            const SizedBox(height: 20),
            Text('Terjadi Kesalahan',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _slate800)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _slate500, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<SensusBloc>()
                  .add(SensusDetailRequested(int.parse(widget.id))),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Delete Sensus Dialog ────────────────────────────────
  void _showDeleteSensusDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: _red, size: 36),
              ),
              const SizedBox(height: 20),
              const Text('Hapus Sensus',
                  style: TextStyle(
                      color: _slate800,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              const SizedBox(height: 12),
              const Text(
                'Apakah Anda yakin ingin menghapus data sensus ini?',
                textAlign: TextAlign.center,
                style: TextStyle(color: _slate500, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: _slate200),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal',
                          style: TextStyle(
                              color: _slate500,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          final repo = context.read<SensusRepository>();
                          await repo.deleteSensus(id);
                          if (mounted) {
                            CustomSnackbar.showSuccess(context, 'Sensus berhasil dihapus');
                            context.pop();
                            context
                                .read<SensusBloc>()
                                .add(SensusFetchRequested());
                          }
                        } catch (e) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            CustomSnackbar.showError(context, 'Gagal menghapus: $e');
                          }
                        }
                      },
                      child: const Text('Hapus',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Delete Gallery Photo Dialog ─────────────────────────
  void _showDeleteGaleriSensusDialog(
      BuildContext context, int galeriId, int sensusId) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: _red, size: 36),
              ),
              const SizedBox(height: 20),
              const Text('Hapus Foto',
                  style: TextStyle(
                      color: _slate800,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              const SizedBox(height: 12),
              const Text(
                'Apakah Anda yakin ingin menghapus foto ini dari galeri?',
                textAlign: TextAlign.center,
                style: TextStyle(color: _slate500, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: _slate200),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal',
                          style: TextStyle(
                              color: _slate500,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          final repo = context.read<SensusRepository>();
                          await repo.deleteGaleriPhoto(galeriId);
                          if (mounted) {
                            CustomSnackbar.showSuccess(context, 'Foto berhasil dihapus');
                            context
                                .read<SensusBloc>()
                                .add(SensusDetailRequested(sensusId));
                          }
                        } catch (e) {
                          if (mounted) {
                            CustomSnackbar.showError(context, 'Gagal menghapus foto: $e');
                          }
                        }
                      },
                      child: const Text('Hapus',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Main Content ────────────────────────────────────────
  Widget _buildDetailContent(BuildContext context, SensusModel sensus) {
    final authState = context.read<AuthBloc>().state;
    bool isAdmin = false;
    bool isLoggedIn = false;
    int? currentUserId;
    if (authState is AuthAuthenticated) {
      isLoggedIn = true;
      isAdmin = authState.user?.role?.toLowerCase() == 'admin';
      currentUserId = authState.user?.id;
    }
    bool canEdit = isAdmin || (isLoggedIn && currentUserId == sensus.userId);

    final int totalVotes = sensus.totalValid + sensus.totalInvalid;
    final int accuracy =
        totalVotes > 0 ? ((sensus.totalValid / totalVotes) * 100).round() : 0;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── Hero Section ──────────────────────────
              SliverToBoxAdapter(
                child: _buildHeroSection(sensus),
              ),

              // ─── Content Cards ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      _buildTrustScoreCard(context, sensus, accuracy,
                          totalVotes),
                      const SizedBox(height: 16),
                      _buildDetailInfoCard(sensus),
                      const SizedBox(height: 16),
                      _buildContributorCard(sensus),
                      if (sensus.galeri.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildGalleryCard(
                            sensus, isAdmin, isLoggedIn, currentUserId),
                      ],
                      const SizedBox(height: 88),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ─── Top Action Buttons ──────────────────────
          _buildTopActionButtons(
              context, sensus, isAdmin, isLoggedIn, canEdit),
        ],
      ),
    );
  }

  // ─── Hero Image Section ──────────────────────────────────
  Widget _buildHeroSection(SensusModel sensus) {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          sensus.fullFotoBuktiUrl != null
              ? CachedNetworkImage(
                  imageUrl: sensus.fullFotoBuktiUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: _navy.withValues(alpha: 0.1),
                    child: const Center(
                        child: CircularProgressIndicator(color: _navy)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_navy, _navyDark],
                      ),
                    ),
                    child: const Center(
                        child: Icon(Icons.train_rounded,
                            size: 80, color: Colors.white38)),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_navy, _navyDark],
                    ),
                  ),
                  child: const Center(
                      child: Icon(Icons.train_rounded,
                          size: 80, color: Colors.white38)),
                ),

          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Title overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sensus.nomorKa ?? '-',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              sensus.namaKa ?? 'Kereta Api',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: _navy,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sensus.nomorSeriLokomotif ?? '-',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _navy.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Trust score badge
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              sensus.trustScore > 0
                                  ? '+${sensus.trustScore.toInt()}'
                                  : sensus.trustScore.toInt().toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: sensus.trustScore >= 0 ? _navy : _red,
                              ),
                            ),
                            const Text('/10',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _slate400,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top Action Buttons ──────────────────────────────────
  Widget _buildTopActionButtons(BuildContext context, SensusModel sensus,
      bool isAdmin, bool isLoggedIn, bool canEdit) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: () => context.pop(),
          ),
          if (isLoggedIn && !canEdit)
            _buildCircleButton(
              icon: Icons.report_outlined,
              onPressed: () => _showReportDialog(context, sensus),
            ),
          if (isLoggedIn && canEdit)
            _buildCircleButton(
              icon: Icons.delete_outline,
              onPressed: () => _showDeleteSensusDialog(context, sensus.id),
            ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  // ─── Trust Score Card ────────────────────────────────────
  Widget _buildTrustScoreCard(BuildContext context, SensusModel sensus,
      int accuracy, int totalVotes) {

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified_user_rounded,
                    color: _navy, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Tingkat Kepercayaan',
                    style: TextStyle(
                        color: _slate800,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accuracy >= 50
                      ? _green.withValues(alpha: 0.1)
                      : _red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$accuracy%',
                  style: TextStyle(
                      color: accuracy >= 50 ? _green : _red,
                      fontWeight: FontWeight.w800,
                      fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: _slate100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: totalVotes > 0
                      ? (sensus.totalValid / totalVotes)
                      : 0.5,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34D399), _green],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Vote counts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${sensus.totalValid} Valid',
                  style: const TextStyle(
                      fontSize: 12,
                      color: _green,
                      fontWeight: FontWeight.w600)),
              Text('${sensus.totalInvalid} Invalid',
                  style: const TextStyle(
                      fontSize: 12,
                      color: _red,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),

          // Vote Buttons
          Row(
            children: [
              Expanded(
                child: _buildVoteButton(
                  context: context,
                  sensus: sensus,
                  voteType: 'Valid',
                  icon: Icons.thumb_up_rounded,
                  label: 'Valid (${sensus.totalValid})',
                  activeColor: _green,
                  isActive: sensus.userVote == 'Valid',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVoteButton(
                  context: context,
                  sensus: sensus,
                  voteType: 'Invalid',
                  icon: Icons.thumb_down_rounded,
                  label: 'Invalid (${sensus.totalInvalid})',
                  activeColor: _red,
                  isActive: sensus.userVote == 'Invalid',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton({
    required BuildContext context,
    required SensusModel sensus,
    required String voteType,
    required IconData icon,
    required String label,
    required Color activeColor,
    required bool isActive,
  }) {
    return Material(
      color: isActive ? activeColor : activeColor.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _handleVote(context, sensus, voteType),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? activeColor
                  : activeColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isActive ? Colors.white : activeColor, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: isActive ? Colors.white : activeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Vote Handler ────────────────────────────────────────
  void _handleVote(BuildContext context, SensusModel sensus, String voteType) {
    if (sensus.userVote == voteType) {
      CustomSnackbar.showSuccess(context, 'Anda sudah memilih $voteType');
      return;
    }

    if (sensus.userVote != null) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _navy.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.compare_arrows_rounded,
                      color: _navy, size: 36),
                ),
                const SizedBox(height: 20),
                const Text('Ubah Pilihan?',
                    style: TextStyle(
                        color: _slate800,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
                const SizedBox(height: 12),
                Text(
                  'Anda sebelumnya memilih ${sensus.userVote}. Ubah menjadi $voteType?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _slate500, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          side: const BorderSide(color: _slate200),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal',
                            style: TextStyle(
                                color: _slate500,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          context
                              .read<SensusBloc>()
                              .add(SensusVoteRequested(sensus.id, voteType));
                        },
                        child: const Text('Ya, Ubah',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      context
          .read<SensusBloc>()
          .add(SensusVoteRequested(sensus.id, voteType));
    }
  }

  // ─── Detail Info Card ────────────────────────────────────
  Widget _buildDetailInfoCard(SensusModel sensus) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Informasi Detail',
                  style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),

          _buildInfoRow(
            icon: Icons.local_offer_outlined,
            iconBgColor: _slate100,
            iconColor: _navy,
            label: 'Nomor Lokomotif',
            value: sensus.nomorSeriLokomotif ?? '-',
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            iconBgColor: const Color(0xFFFFF7ED),
            iconColor: _orange,
            label: 'Lokasi Pengamatan',
            value: sensus.lokasi ?? 'Lokasi tidak diketahui',
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            iconBgColor: const Color(0xFFF0FDF4),
            iconColor: _green,
            label: 'Waktu Sensus',
            value:
                DateFormat('dd MMMM yyyy, HH:mm').format(sensus.waktuSensus),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: _slate400, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      color: _slate800,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        color: _slate200.withValues(alpha: 0.6),
        height: 1,
      ),
    );
  }

  // ─── Contributor Card ────────────────────────────────────
  Widget _buildContributorCard(SensusModel sensus) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _orange.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: _navy,
              backgroundImage: sensus.fullUserFotoProfilUrl != null
                  ? CachedNetworkImageProvider(sensus.fullUserFotoProfilUrl!)
                  : null,
              child: sensus.fullUserFotoProfilUrl == null
                  ? Text(
                      _getInitials(sensus.username ?? 'User'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kontributor',
                    style: TextStyle(color: _slate400, fontSize: 12)),
                const SizedBox(height: 2),
                Text(sensus.username ?? 'Anonim',
                    style: const TextStyle(
                        color: _slate800,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              sensus.userRole ?? 'Spotter',
              style: const TextStyle(
                  color: _navy, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  // ─── Gallery Card ────────────────────────────────────────
  Widget _buildGalleryCard(
      SensusModel sensus, bool isAdmin, bool isLoggedIn, int? currentUserId) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Galeri Foto',
                  style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _slate100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${sensus.galeri.length} foto',
                    style: const TextStyle(
                        color: _slate500,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sensus.galeri.length,
              itemBuilder: (context, index) {
                final galeri = sensus.galeri[index];
                return GestureDetector(
                  onTap: () => _showFullScreenImage(galeri.fullFotoUrl),
                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: galeri.fullFotoUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: _slate100,
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      color: _navy, strokeWidth: 2)),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: _slate100,
                              child: const Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: _slate400)),
                            ),
                          ),
                        ),
                      ),
                      if (isAdmin ||
                          (isLoggedIn && currentUserId == galeri.userId))
                        Positioned(
                          top: 6,
                          right: 18,
                          child: GestureDetector(
                            onTap: () => _showDeleteGaleriSensusDialog(
                                context, galeri.id, sensus.id),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: _red.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Report Dialog ───────────────────────────────────────
  void _showReportDialog(BuildContext context, SensusModel sensus) {
    final TextEditingController alasanController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded,
                          color: _orange, size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text('Laporkan Sensus',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _slate800,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    const SizedBox(height: 12),
                    const Text(
                      'Jelaskan alasan mengapa data sensus ini tidak valid atau perlu dihapus:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _slate500, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: alasanController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText:
                            'Misal: Foto tidak jelas, data tidak sesuai...',
                        hintStyle: const TextStyle(
                            color: _slate400, fontSize: 13),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _slate200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: _navy, width: 1.5),
                        ),
                        filled: true,
                        fillColor: _slate50,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _slate200),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Batal',
                                style: TextStyle(
                                    color: _slate500,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (alasanController.text
                                        .trim()
                                        .isEmpty) {
                                      CustomSnackbar.showError(context, 'Alasan wajib diisi!');
                                      return;
                                    }
                                    setDialogState(
                                        () => isSubmitting = true);
                                    try {
                                      final repo = context
                                          .read<LaporanHapusSensusRepository>();
                                      await repo.createLaporan(sensus.id,
                                          alasanController.text.trim());
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                        CustomSnackbar.showSuccess(context, 'Laporan berhasil dikirim.');
                                      }
                                    } catch (e) {
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                      }
                                      if (context.mounted) {
                                        CustomSnackbar.showError(context, e.toString());
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Kirim Laporan',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Bottom Action Bar ───────────────────────────────────
  Widget _buildBottomActionBar(BuildContext context, SensusModel sensus) {
    final authState = context.read<AuthBloc>().state;
    bool canEdit = false;
    bool isAdmin = false;

    if (authState is AuthAuthenticated && authState.user != null) {
      final user = authState.user!;
      isAdmin = user.role == 'Admin';
      canEdit = (user.id == sensus.userId || isAdmin);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (canEdit) ...[
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => EditSensusDialog(sensus: sensus),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined,
                      color: _navy, size: 18),
                  label: const Text('Edit',
                      style: TextStyle(
                          color: _navy, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: _slate200),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (isAdmin)
                OutlinedButton(
                  onPressed: () => _showDeleteSensusDialog(context, sensus.id),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 14),
                    side: const BorderSide(color: _red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: _red, size: 20),
                ),
              if (isAdmin) const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 80);
                  if (pickedFile != null) {
                    final formData = FormData.fromMap({
                      'foto_galeri':
                          await MultipartFile.fromFile(pickedFile.path),
                    });
                    if (mounted) {
                      context.read<SensusBloc>().add(
                          SensusAddGalleryPhotoRequested(
                              sensus.id, formData));
                    }
                  }
                },
                icon: const Icon(Icons.camera_alt_outlined,
                    color: Colors.white, size: 18),
                label: const Text('Foto',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
