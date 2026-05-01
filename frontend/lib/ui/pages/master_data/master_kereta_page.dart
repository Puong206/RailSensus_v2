import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/admin_master/admin_master_bloc.dart';
import '../../../logic/bloc/admin_master/admin_master_event.dart';
import '../../../logic/bloc/admin_master/admin_master_state.dart';
import '../../../data/models/kereta_model.dart';
import '../../widgets/custom_snackbar.dart';

class MasterKeretaPage extends StatefulWidget {
  const MasterKeretaPage({super.key});

  @override
  State<MasterKeretaPage> createState() => _MasterKeretaPageState();
}

class _MasterKeretaPageState extends State<MasterKeretaPage> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    context.read<AdminMasterBloc>().add(const LoadKeretaEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentPage = 1;
    });
    context.read<AdminMasterBloc>().add(LoadKeretaEvent(query: query));
  }

  void _showFormDialog({KeretaModel? kereta}) {
    final bool isEdit = kereta != null;
    final namaController =
        TextEditingController(text: isEdit ? kereta.namaKa : '');
    final nomorController =
        TextEditingController(text: isEdit ? kereta.nomorKa : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF153D77).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit_note : Icons.add_circle_outline,
                      color: const Color(0xFF153D77),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    isEdit ? 'Edit Kereta' : 'Tambah Kereta',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildModernTextField(
                controller: namaController,
                label: 'Nama Kereta',
                icon: Icons.directions_railway_filled,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: nomorController,
                label: isEdit ? 'Nomor Kereta' : 'Nomor Kereta (Pisahkan dengan koma)',
                icon: Icons.tag,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF153D77),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 5,
                    shadowColor: const Color(0xFF153D77).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (namaController.text.trim().isEmpty ||
                        nomorController.text.trim().isEmpty) {
                      CustomSnackbar.showError(
                          context, 'Semua kolom harus diisi');
                      return;
                    }

                    final data = {
                      'nama_ka': namaController.text.trim(),
                      'nomor_ka': nomorController.text.trim(),
                    };

                    if (isEdit) {
                      context
                          .read<AdminMasterBloc>()
                          .add(UpdateKeretaEvent(kereta.id, data));
                    } else {
                      context
                          .read<AdminMasterBloc>()
                          .add(CreateKeretaEvent(data));
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    isEdit ? 'Simpan Perubahan' : 'Simpan Kereta',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF153D77), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }

  void _showDeleteDialog(KeretaModel kereta) {
    showDialog(
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
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hapus Kereta?',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    fontFamily: 'Plus Jakarta Sans'),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus KA ${kereta.namaKa}? Data yang dihapus tidak dapat dikembalikan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                    fontFamily: 'Plus Jakarta Sans'),
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
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal',
                          style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Plus Jakarta Sans')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        context
                            .read<AdminMasterBloc>()
                            .add(DeleteKeretaEvent(kereta.id));
                        Navigator.pop(context);
                      },
                      child: const Text('Hapus',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Plus Jakarta Sans')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF153D77)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/images/RailSensus_Logo.png', height: 32),
        centerTitle: true,
      ),
      body: BlocConsumer<AdminMasterBloc, AdminMasterState>(
        listener: (context, state) {
          if (state is AdminMasterActionSuccess) {
            CustomSnackbar.showSuccess(context, state.message);
          } else if (state is AdminMasterError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Master Kereta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF153D77),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showFormDialog(),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Tambah'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9428),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau nomor KA...',
                      hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 14),
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(AdminMasterState state) {
    if (state is AdminMasterLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is AdminKeretaLoaded) {
      if (state.keretas.isEmpty) {
        return const Center(child: Text('Tidak ada data kereta.'));
      }
      final Map<String, List<KeretaModel>> groupedKeretas = {};
      for (var k in state.keretas) {
        if (!groupedKeretas.containsKey(k.namaKa)) {
          groupedKeretas[k.namaKa] = [];
        }
        groupedKeretas[k.namaKa]!.add(k);
      }

      final keys = groupedKeretas.keys.toList();

      final totalItems = keys.length;
      final totalPages = (totalItems / _itemsPerPage).ceil();
      if (_currentPage > totalPages && totalPages > 0) {
        _currentPage = totalPages;
      }

      final startIndex = (_currentPage - 1) * _itemsPerPage;
      final endIndex = (startIndex + _itemsPerPage > totalItems)
          ? totalItems
          : startIndex + _itemsPerPage;
      final paginatedKeys = keys.sublist(startIndex, endIndex);

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
              itemCount: paginatedKeys.length,
              itemBuilder: (context, index) {
                final namaKa = paginatedKeys[index];
                final keretasGroup = groupedKeretas[namaKa]!;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Material(
                      color: Colors.transparent,
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          childrenPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF153D77).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.train,
                                color: Color(0xFF153D77), size: 28),
                          ),
                          title: Text(
                            namaKa,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Text(
                            '${keretasGroup.length} Nomor Kereta',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          children: keretasGroup.map((kereta) {
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showFormDialog(kereta: kereta),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 72, right: 16, top: 12, bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          kereta.nomorKa,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.edit_note,
                                            color: Color(0xFF3B82F6), size: 24),
                                        onPressed: () =>
                                            _showFormDialog(kereta: kereta),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red, size: 24),
                                        onPressed: () =>
                                            _showDeleteDialog(kereta),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Pagination Controls
          if (totalPages > 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Tampil:',
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<int>(
                          initialValue: _itemsPerPage,
                          tooltip: 'Pilih jumlah item',
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Colors.white,
                          elevation: 4,
                          position: PopupMenuPosition.under,
                          onSelected: (int newValue) {
                            setState(() {
                              _itemsPerPage = newValue;
                              _currentPage = 1;
                            });
                          },
                          itemBuilder: (context) => [10, 20, 30].map((value) => PopupMenuItem<int>(
                            value: value,
                            child: Text(value.toString(), style: const TextStyle(color: Color(0xFF153D77), fontWeight: FontWeight.bold)),
                          )).toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_itemsPerPage.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF153D77))),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          color: _currentPage > 1
                              ? const Color(0xFF153D77)
                              : const Color(0xFFCBD5E1),
                          onPressed: _currentPage > 1
                              ? () {
                                  setState(() {
                                    _currentPage--;
                                  });
                                }
                              : null,
                        ),
                        Text(
                          '$_currentPage dari $totalPages',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          color: _currentPage < totalPages
                              ? const Color(0xFF153D77)
                              : const Color(0xFFCBD5E1),
                          onPressed: _currentPage < totalPages
                              ? () {
                                  setState(() {
                                    _currentPage++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }
    return const Center(child: Text('Memuat data...'));
  }
}
