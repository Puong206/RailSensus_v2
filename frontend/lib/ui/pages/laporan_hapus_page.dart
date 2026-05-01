import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/laporan_hapus_model.dart';
import '../../data/repositories/laporan_hapus_repository.dart';
import '../../logic/bloc/lokomotif/lokomotif_bloc.dart';
import '../../logic/bloc/lokomotif/lokomotif_event.dart';
import '../widgets/custom_snackbar.dart';

class LaporanHapusPage extends StatefulWidget {
  final bool showAppBar;
  
  const LaporanHapusPage({super.key, this.showAppBar = true});

  @override
  State<LaporanHapusPage> createState() => _LaporanHapusPageState();
}

class _LaporanHapusPageState extends State<LaporanHapusPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<LaporanHapusModel> _laporan = [];
  bool _isLoading = true;
  String? _error;

  int _currentPage = 1;
  int _limit = 10;
  int _totalPages = 1;

  final List<String> _statuses = ['Menunggu', 'Disetujui', 'Ditolak'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentPage = 1;
        });
        _fetchLaporan();
      }
    });
    _fetchLaporan();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchLaporan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<LaporanHapusRepository>();
      final data = await repo.getAllLaporan(
        status: _statuses[_tabController.index],
        page: _currentPage,
        limit: _limit,
      );
      setState(() {
        _laporan = List<LaporanHapusModel>.from(data['list']);
        _totalPages = data['totalPages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final status = _statuses[_tabController.index];
    if (status == 'Menunggu') return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
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
                child: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444), size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bersihkan Riwayat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus semua laporan yang $status? Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
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
                      onPressed: () => Navigator.pop(context, false),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Hapus',
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
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = context.read<LaporanHapusRepository>();
      await repo.clearHistory(status);
      _currentPage = 1;
      await _fetchLaporan();
      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Riwayat berhasil dibersihkan.');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, '$e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setujui(LaporanHapusModel laporan) async {
    try {
      final repo = context.read<LaporanHapusRepository>();
      await repo.setujuiLaporan(laporan.laporanId);
      // Refresh list bloc
      if (mounted) {
        context.read<LokomotifBloc>().add(LokomotifFetchRequested());
      }
      await _fetchLaporan();
      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Laporan disetujui. Lokomotif telah dihapus.');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, '$e');
      }
    }
  }

  Future<void> _tolak(LaporanHapusModel laporan) async {
    try {
      final repo = context.read<LaporanHapusRepository>();
      await repo.tolakLaporan(laporan.laporanId);
      await _fetchLaporan();
      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Laporan telah ditolak.');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, '$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: const Color(0xFF153D77),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Laporan Penghapusan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (_tabController.index > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Bersihkan Riwayat ${_statuses[_tabController.index]}',
              onPressed: _clearHistory,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLaporan,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF9428),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Menunggu'),
            Tab(text: 'Disetujui'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ) : PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF153D77),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF153D77),
                  unselectedLabelColor: const Color(0xFF94A3B8),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Menunggu'),
                    Tab(text: 'Disetujui'),
                    Tab(text: 'Ditolak'),
                  ],
                ),
              ),
              if (_tabController.index > 0)
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Color(0xFFEF4444)),
                  tooltip: 'Bersihkan Riwayat ${_statuses[_tabController.index]}',
                  onPressed: _clearHistory,
                ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF153D77)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF64748B))),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchLaporan,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF153D77),
                          foregroundColor: Colors.white,
                        ),
                      )
                    ],
                  ),
                )
              : _buildList(),
    );
  }

  Widget _buildList() {
    if (_laporan.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _tabController.index == 0
                  ? Icons.inbox_outlined
                  : _tabController.index == 1
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
              size: 64,
              color: const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada laporan ${_statuses[_tabController.index].toLowerCase()}',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _laporan.length,
            itemBuilder: (context, index) => _buildCard(_laporan[index]),
          ),
        ),
        _buildPagination(),
      ],
    );
  }

  Widget _buildCard(LaporanHapusModel laporan) {
    final lokoName = laporan.lokomotif != null
        ? '${laporan.lokomotif!["tipe_model"]} ${laporan.lokomotif!["seri_model"]}'
        : (laporan.lokoId != null ? 'Lokomotif #${laporan.lokoId}' : 'Lokomotif (Dihapus)');
    final depoName = laporan.lokomotif?["depo"]?["nama_depo"] ?? '-';
    final pelaporName = laporan.pelapor?["username"] ?? '-';
    final pelaporEmail = laporan.pelapor?["email"] ?? '-';
    final tanggal = laporan.dilaporkanPada != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(laporan.dilaporkanPada!)
        : '-';

    final Color statusColor;
    final IconData statusIcon;
    switch (laporan.statusLaporan) {
      case 'Disetujui':
        statusColor = const Color(0xFF22C55E);
        statusIcon = Icons.check_circle;
        break;
      case 'Ditolak':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = const Color(0xFFFF9428);
        statusIcon = Icons.access_time;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Loko name + status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF153D77).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.train, color: Color(0xFF153D77), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lokoName,
                              style: const TextStyle(
                                  color: Color(0xFF153D77),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 2),
                            Text(depoName, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                          ]),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(laporan.statusLaporan,
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Alasan
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Alasan Penghapusan',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(laporan.alasanHapus,
                          style: const TextStyle(color: Color(0xFF334155), fontSize: 14, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Pelapor + Tanggal
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text('$pelaporName • $pelaporEmail',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(tanggal, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons (only for Menunggu)
          if (laporan.statusLaporan == 'Menunggu') ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _tolak(laporan),
                      icon: const Icon(Icons.close, size: 16, color: Color(0xFFEF4444)),
                      label: const Text('Tolak', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _setujui(laporan),
                      icon: const Icon(Icons.check, size: 16, color: Colors.white),
                      label: const Text('Setujui & Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('Tampil',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _limit,
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                    items: [10, 25, 50].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString(),
                            style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _limit = newValue;
                          _currentPage = 1;
                        });
                        _fetchLaporan();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildPageButton(
                icon: Icons.chevron_left,
                onTap: _currentPage > 1
                    ? () {
                        setState(() => _currentPage--);
                        _fetchLaporan();
                      }
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Halaman $_currentPage dari $_totalPages',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              _buildPageButton(
                icon: Icons.chevron_right,
                onTap: _currentPage < _totalPages
                    ? () {
                        setState(() => _currentPage++);
                        _fetchLaporan();
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton({required IconData icon, VoidCallback? onTap}) {
    bool isDisabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
              color: isDisabled
                  ? const Color(0xFFF1F5F9)
                  : const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon,
            color: isDisabled
                ? const Color(0xFFCBD5E1)
                : const Color(0xFF64748B),
            size: 18),
      ),
    );
  }
}
