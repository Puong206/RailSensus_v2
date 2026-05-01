import '../widgets/custom_snackbar.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/lokomotif_model.dart';
import '../../data/repositories/lokomotif_repository.dart';
import '../../data/repositories/laporan_hapus_repository.dart';
import '../../logic/bloc/auth/auth_bloc.dart';
import '../../logic/bloc/auth/auth_state.dart';
import '../../logic/bloc/lokomotif/lokomotif_bloc.dart';
import '../../logic/bloc/lokomotif/lokomotif_event.dart';
import '../pages/lokomotif_form_page.dart';

class DetailLokomotifPage extends StatefulWidget {
  final LokomotifModel data;
  const DetailLokomotifPage({super.key, required this.data});

  @override
  State<DetailLokomotifPage> createState() => _DetailLokomotifPageState();
}

class _DetailLokomotifPageState extends State<DetailLokomotifPage>
    with SingleTickerProviderStateMixin {
  late LokomotifModel currentData;
  bool _isUploading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

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
  void initState() {
    super.initState();
    currentData = widget.data;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─── Edit Form ───────────────────────────────────────────
  void _showEditForm(BuildContext context, LokomotifModel lokomotif) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LokomotifFormPage(lokomotif: lokomotif),
      ),
    ).then((result) async {
      if (result == true) {
        try {
          final repo = context.read<LokomotifRepository>();
          final updatedData = await repo.getLokomotifById(lokomotif.id);
          context.read<LokomotifBloc>().add(LokomotifFetchRequested());
          if (mounted) {
            setState(() {
              currentData = updatedData;
            });
            CustomSnackbar.showSuccess(context, 'Lokomotif berhasil diperbarui');
          }
        } catch (e) {
          if (mounted) {
            CustomSnackbar.showError(context, 'Gagal memuat ulang data: $e');
          }
        }
      }
    });
  }

  // ─── Upload Gallery Photo ────────────────────────────────
  Future<void> _uploadGaleriFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isUploading = true;
      });
      try {
        final repo = context.read<LokomotifRepository>();
        final newPhoto =
            await repo.uploadGaleriPhoto(currentData.id, image.path);
        context.read<LokomotifBloc>().add(LokomotifFetchRequested());
        if (mounted) {
          setState(() {
            currentData.galeri.add(newPhoto);
          });
          CustomSnackbar.showSuccess(context, 'Foto berhasil ditambahkan ke galeri');
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.showError(context, 'Error: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  // ─── Delete Lokomotif Dialog ─────────────────────────────
  void _showDeleteLokomotifDialog(BuildContext context) {
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
              const Text('Hapus Lokomotif',
                  style: TextStyle(
                      color: _slate800,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              const SizedBox(height: 12),
              const Text(
                'Apakah Anda yakin ingin menghapus data lokomotif ini?',
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
                          final repo = context.read<LokomotifRepository>();
                          await repo.deleteLokomotif(currentData.id);
                          context
                              .read<LokomotifBloc>()
                              .add(LokomotifFetchRequested());
                          if (mounted) {
                            CustomSnackbar.showSuccess(context, 'Lokomotif berhasil dihapus');
                            context.pop();
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

  // ─── Delete Gallery Dialog ───────────────────────────────
  void _showDeleteGaleriDialog(BuildContext context, int galeriId) {
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
                          final repo = context.read<LokomotifRepository>();
                          await repo.deleteGaleriPhoto(galeriId);
                          if (mounted) {
                            setState(() {
                              currentData.galeri
                                  .removeWhere((g) => g.galeriId == galeriId);
                            });
                            CustomSnackbar.showSuccess(context, 'Foto berhasil dihapus');
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

  // ─── Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    bool isAdmin = false;
    bool isLoggedIn = false;
    int? currentUserId;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      isLoggedIn = true;
      isAdmin = authState.user?.role?.toLowerCase() == 'admin';
      currentUserId = authState.user?.id;
    }

    bool canEdit = isAdmin ||
        (isLoggedIn &&
            currentUserId != null &&
            currentUserId == currentData.createdBy);
    bool canAddPhoto = isLoggedIn;

    return Scaffold(
      backgroundColor: _slate50,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── Hero Section ──────────────────────────
                SliverToBoxAdapter(
                  child: _buildHeroSection(),
                ),

                // ─── Content ───────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Spec Grid ───────────────────────
                        _buildSpecGrid(),
                        const SizedBox(height: 16),

                        // ─── Contributor ─────────────────────
                        if (currentData.creatorName != null)
                          _buildContributorCard(),
                        if (currentData.creatorName != null)
                          const SizedBox(height: 16),

                        // ─── Keterangan ──────────────────────
                        if (currentData.keterangan != null &&
                            currentData.keterangan!.isNotEmpty)
                          _buildKeteranganCard(),
                        if (currentData.keterangan != null &&
                            currentData.keterangan!.isNotEmpty)
                          const SizedBox(height: 16),

                        // ─── Gallery ─────────────────────────
                        _buildGallerySection(
                            isAdmin, isLoggedIn, currentUserId),

                        const SizedBox(height: 88),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ─── Top Action Buttons ──────────────────────
            _buildTopActionButtons(
                context, isAdmin, isLoggedIn, canEdit),
          ],
        ),
      ),

      // ─── Bottom Action Bar ───────────────────────────
      bottomNavigationBar: (canEdit || canAddPhoto)
          ? _buildBottomBar(canEdit, canAddPhoto)
          : null,
    );
  }

  // ─── Hero Section ────────────────────────────────────────
  Widget _buildHeroSection() {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          currentData.fullFotoUrl != null &&
                  currentData.fullFotoUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: currentData.fullFotoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: _navy.withValues(alpha: 0.1),
                    child: const Center(
                        child: CircularProgressIndicator(color: _navy)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: const BoxDecoration(
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
                  decoration: const BoxDecoration(
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
                                currentData.tipeModel,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${currentData.tipeModel} ${currentData.seriModel}',
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
                              currentData.sumberTenaga,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _navy.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: currentData.status == 'Siap Operasi'
                              ? _green.withValues(alpha: 0.15)
                              : _orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: currentData.status == 'Siap Operasi'
                                ? _green.withValues(alpha: 0.3)
                                : _orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          currentData.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: currentData.status == 'Siap Operasi'
                                ? _green
                                : _orange,
                          ),
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
  Widget _buildTopActionButtons(
      BuildContext context, bool isAdmin, bool isLoggedIn, bool canEdit) {
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
              onPressed: () => _showLaporanHapusDialog(context),
            ),
          if (isLoggedIn && canEdit)
            _buildCircleButton(
              icon: Icons.delete_outline,
              onPressed: () => _showDeleteLokomotifDialog(context),
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

  // ─── Spec Grid ───────────────────────────────────────────
  Widget _buildSpecGrid() {
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
        children: [
          // Header
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
              const Text('Spesifikasi',
                  style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),

          // Spec items in 2-column grid
          Row(
            children: [
              Expanded(
                child: _buildSpecItem(
                  icon: Icons.train_outlined,
                  iconColor: const Color(0xFF4F46E5),
                  iconBg: const Color(0xFFEEF2FF),
                  label: 'Seri Lokomotif',
                  value: currentData.tipeModel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSpecItem(
                  icon: Icons.location_on_outlined,
                  iconColor: _orange,
                  iconBg: const Color(0xFFFFF7ED),
                  label: 'Depo Induk',
                  value: currentData.depoName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSpecItem(
                  icon: Icons.palette_outlined,
                  iconColor: const Color(0xFFEC4899),
                  iconBg: const Color(0xFFFDF2F8),
                  label: 'Livery',
                  value: currentData.livery.split(' ').first,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSpecItem(
                  icon: Icons.bolt_outlined,
                  iconColor: _green,
                  iconBg: const Color(0xFFF0FDF4),
                  label: 'Sumber Tenaga',
                  value: currentData.sumberTenaga.length > 12
                      ? currentData.sumberTenaga.split(' ').first
                      : currentData.sumberTenaga,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _slate50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _slate200.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: _slate400, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: _navy),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Contributor Card ────────────────────────────────────
  Widget _buildContributorCard() {
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
            child: currentData.fullCreatorFotoUrl != null
                ? CircleAvatar(
                    radius: 22,
                    backgroundColor: _navy,
                    backgroundImage: CachedNetworkImageProvider(
                        currentData.fullCreatorFotoUrl!),
                  )
                : CircleAvatar(
                    radius: 22,
                    backgroundColor: _navy.withValues(alpha: 0.08),
                    child:
                        const Icon(Icons.person_outline, color: _navy, size: 22),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ditambahkan Oleh',
                    style: TextStyle(fontSize: 12, color: _slate400)),
                const SizedBox(height: 2),
                Text(currentData.creatorName!,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _navy)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person, color: _navy, size: 18),
          ),
        ],
      ),
    );
  }

  // ─── Keterangan Card ─────────────────────────────────────
  Widget _buildKeteranganCard() {
    return Container(
      width: double.infinity,
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
              const Text('Keterangan',
                  style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _slate200.withValues(alpha: 0.5)),
            ),
            child: Text(
              currentData.keterangan!,
              style: const TextStyle(
                  fontSize: 14, color: _slate500, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Gallery Section ─────────────────────────────────────
  Widget _buildGallerySection(
      bool isAdmin, bool isLoggedIn, int? currentUserId) {
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
                child: Text('${currentData.galeri.length} foto',
                    style: const TextStyle(
                        color: _slate500,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          currentData.galeri.isNotEmpty
              ? GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: currentData.galeri.length,
                  itemBuilder: (context, index) {
                    final foto = currentData.galeri[index];
                    return GestureDetector(
                      onTap: () => _showFullScreenImage(foto.fullFotoUrl),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
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
                                imageUrl: foto.fullFotoUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: _slate100,
                                  child: const Center(
                                      child: CircularProgressIndicator(
                                          color: _navy, strokeWidth: 2)),
                                ),
                                errorWidget: (context, url, error) =>
                                    Container(
                                  color: _slate100,
                                  child: const Center(
                                      child: Icon(Icons.image_not_supported,
                                          color: _slate400)),
                                ),
                              ),
                            ),
                          ),
                          if (isAdmin ||
                              (isLoggedIn &&
                                  currentUserId == foto.userId))
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _showDeleteGaleriDialog(
                                    context, foto.galeriId),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: _red.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.2),
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
                )
              : Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: _slate50,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: _slate200.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 40, color: _slate400.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      const Text('Belum ada foto di galeri',
                          style: TextStyle(color: _slate400, fontSize: 14)),
                    ],
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

  // ─── Bottom Action Bar ───────────────────────────────────
  Widget _buildBottomBar(bool canEdit, bool canAddPhoto) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canEdit)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showEditForm(context, currentData),
                icon: const Icon(Icons.edit_outlined,
                    color: _navy, size: 18),
                label: const Text('Edit Data',
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
          if (canEdit && canAddPhoto) const SizedBox(width: 12),
          if (canAddPhoto)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadGaleriFoto,
                icon: _isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.camera_alt_outlined,
                        color: Colors.white, size: 18),
                label: Text(
                    _isUploading ? 'Mengunggah...' : 'Tambah Foto',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  disabledBackgroundColor:
                      _orange.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Report Dialog ───────────────────────────────────────
  void _showLaporanHapusDialog(BuildContext context) {
    final alasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          bool isLoading = false;
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
                  const Text('Laporkan Penghapusan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _slate800,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  const SizedBox(height: 12),
                  Text(
                    'Kirim permintaan ke admin untuk menghapus ${currentData.tipeModel} ${currentData.seriModel}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: _slate500, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Alasan Penghapusan',
                        style: TextStyle(
                            color: _slate800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: alasanController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText:
                          'Jelaskan alasan mengapa lokomotif ini perlu dihapus...',
                      hintStyle:
                          const TextStyle(color: _slate400, fontSize: 13),
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
                          onPressed: isLoading
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
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (alasanController.text
                                      .trim()
                                      .isEmpty) {
                                    CustomSnackbar.showError(context, 'Alasan wajib diisi!');
                                    return;
                                  }
                                  setDialogState(
                                      () => isLoading = true);
                                  try {
                                    final repo = context
                                        .read<LaporanHapusRepository>();
                                    await repo.createLaporan(
                                        currentData.id,
                                        alasanController.text.trim());
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (context.mounted) {
                                      CustomSnackbar.showSuccess(context, 'Laporan berhasil dikirim ke admin');
                                    }
                                  } catch (e) {
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                    }
                                    if (context.mounted) {
                                      CustomSnackbar.showError(context, '$e');
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
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2))
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
      ),
    );
  }
}
