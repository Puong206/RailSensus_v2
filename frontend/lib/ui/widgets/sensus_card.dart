import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/sensus_model.dart';
import '../../logic/bloc/sensus/sensus_bloc.dart';
import '../../logic/bloc/sensus/sensus_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'shimmer_loader.dart';

class SensusCard extends StatelessWidget {
  final SensusModel sensus;
  final double? width;
  final EdgeInsetsGeometry? margin;

  const SensusCard({super.key, required this.sensus, this.width = 280, this.margin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await context.push('/sensus/detail/${sensus.id}');
        if (context.mounted) {
          context.read<SensusBloc>().add(SensusFeedRestored());
        }
      },
      child: Container(
        margin: margin ?? const EdgeInsets.only(right: 16, bottom: 16),
        width: width,
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Section
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  sensus.fullFotoBuktiUrl != null && sensus.fullFotoBuktiUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: sensus.fullFotoBuktiUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ShimmerLoader(height: 180),
                          errorWidget: (context, url, error) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                  
                  // Gradient Overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),

                  // Top Right Badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9428),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        sensus.nomorKa ?? '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  // Bottom Left Text
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensus.namaKa ?? 'Kereta Api',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          sensus.nomorSeriLokomotif ?? 'CC 206',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Reporter Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF153D77),
                        backgroundImage: sensus.fullUserFotoProfilUrl != null
                            ? CachedNetworkImageProvider(sensus.fullUserFotoProfilUrl!)
                            : null,
                        child: sensus.fullUserFotoProfilUrl == null
                            ? Text(
                                _getInitials(sensus.username ?? 'User'),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sensus.username ?? 'User',
                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(sensus.waktuSensus),
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Right: Trust Score
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Trust Score',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Icon(
                            sensus.trustScore > 0
                                ? Icons.thumb_up
                                : (sensus.trustScore < 0 ? Icons.thumb_down : Icons.thumbs_up_down),
                            size: 14,
                            color: sensus.trustScore > 0
                                ? const Color(0xFF22C55E)
                                : (sensus.trustScore < 0 ? const Color(0xFFEF4444) : const Color(0xFF94A3B8)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sensus.trustScore > 0
                                ? '+${sensus.trustScore.toInt()}'
                                : sensus.trustScore.toInt().toString(),
                            style: TextStyle(
                              color: sensus.trustScore > 0
                                  ? const Color(0xFF22C55E)
                                  : (sensus.trustScore < 0 ? const Color(0xFFEF4444) : const Color(0xFF94A3B8)),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF153D77).withOpacity(0.1),
      child: const Center(
        child: Icon(Icons.train, color: Color(0xFF153D77), size: 40),
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
}
