import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/lokomotif_model.dart';
import '../../data/repositories/laporan_hapus_repository.dart';
import '../../logic/bloc/lokomotif/lokomotif_bloc.dart';
import '../../logic/bloc/lokomotif/lokomotif_event.dart';
import 'shimmer_loader.dart';
import 'custom_snackbar.dart';

class LokomotifCard extends StatelessWidget {
  final LokomotifModel lokomotif;
  final bool isAdmin;
  final bool isLoggedIn;

  const LokomotifCard({
    super.key,
    required this.lokomotif,
    this.isAdmin = false,
    this.isLoggedIn = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/lokomotif/detail/${lokomotif.id}', extra: lokomotif);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF153D77).withOpacity(0.05),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: lokomotif.fullFotoUrl != null && lokomotif.fullFotoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: lokomotif.fullFotoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const ShimmerLoader(height: 96, borderRadius: 0),
                            errorWidget: (context, url, error) => const Icon(Icons.train, color: Color(0xFF153D77), size: 36),
                          )
                        : const Icon(Icons.train, color: Color(0xFF153D77), size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${lokomotif.tipeModel} ${lokomotif.seriModel}',
                          style: const TextStyle(
                            color: Color(0xFF153D77),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              lokomotif.depoName,
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            ),
                          ],
                        ),
                        if (lokomotif.creatorName != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  lokomotif.creatorName!,
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                lokomotif.livery.split(' ').first,
                                style: const TextStyle(color: Color(0xFF153D77), fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: lokomotif.status.toLowerCase() == 'siap operasi'
                                    ? const Color(0xFF22C55E).withOpacity(0.1)
                                    : const Color(0xFFFF9428).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                lokomotif.status.toLowerCase() == 'siap operasi' ? 'Aktif' : 'Non-aktif',
                                style: TextStyle(
                                  color: lokomotif.status.toLowerCase() == 'siap operasi'
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFFF9428),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 24),
                ],
              ),
            ),

            // Action bar — admin: hapus langsung | user: laporkan hapus
            if (isAdmin || isLoggedIn) ...[
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              if (isAdmin)
                InkWell(
                  onTap: () => _showDeleteConfirm(context),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                        SizedBox(width: 4),
                        Text('Hapus', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                )
              else
                InkWell(
                  onTap: () => _showLaporanHapusDialog(context),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(Icons.report_outlined, size: 16, color: Color(0xFFFF9428)),
                        SizedBox(width: 4),
                        Text('Laporkan Hapus', style: TextStyle(color: Color(0xFFFF9428), fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
            ]
          ],
        ),
      ),
    );
  }

  void _showLaporanHapusDialog(BuildContext context) {
    final alasanController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
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
                      color: const Color(0xFFFF9428).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFFF9428),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Laporkan Penghapusan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kirim permintaan ke admin untuk menghapus ${lokomotif.tipeModel} ${lokomotif.seriModel}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Alasan Penghapusan',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: alasanController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
                    decoration: InputDecoration(
                      hintText: 'Jelaskan alasan mengapa lokomotif ini perlu dihapus...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontFamily: 'Plus Jakarta Sans'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF153D77), width: 1.5),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (alasanController.text.trim().isEmpty) {
                                    CustomSnackbar.showError(context, 'Alasan wajib diisi!');
                                    return;
                                  }
                                  setDialogState(() => isLoading = true);
                                  try {
                                    final repo = context.read<LaporanHapusRepository>();
                                    await repo.createLaporan(lokomotif.id, alasanController.text.trim());
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (context.mounted) {
                                      CustomSnackbar.showSuccess(context, 'Laporan berhasil dikirim ke admin');
                                    }
                                  } catch (e) {
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (context.mounted) {
                                      CustomSnackbar.showError(context, '$e');
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9428),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text(
                                  'Kirim Laporan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
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

  void _showDeleteConfirm(BuildContext context) {
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
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hapus Lokomotif',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus ${lokomotif.tipeModel} ${lokomotif.seriModel}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.5,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        context.read<LokomotifBloc>().add(LokomotifDeleteRequested(lokomotif.id));
                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
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
}
