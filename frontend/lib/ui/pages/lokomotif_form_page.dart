import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/custom_snackbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:railsensus/logic/bloc/lokomotif/lokomotif_state.dart';
import '../../data/models/lokomotif_model.dart';
import '../../data/repositories/lokomotif_repository.dart';
import '../../logic/bloc/lokomotif/lokomotif_bloc.dart';
import '../../logic/bloc/lokomotif/lokomotif_event.dart';

class LokomotifFormPage extends StatefulWidget {
  final LokomotifModel? lokomotif;

  const LokomotifFormPage({super.key, this.lokomotif});

  @override
  State<LokomotifFormPage> createState() => _LokomotifFormPageState();
}

class _LokomotifFormPageState extends State<LokomotifFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tipeController;
  late TextEditingController _seriController;
  late TextEditingController _keteranganController;

  int? _selectedDepoId;
  String? _selectedLivery;
  String _selectedStatus = 'Siap Operasi';
  String _selectedSumberTenaga = 'Diesel Elektrik';

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _depoOptions = [];
  bool _isLoadingDepos = true;

  final List<String> _liveryOptions = [
    'Default (Kai Corporate)',
    'Vintage (PJKA/Perumka)',
    'Red and Blue (Perumka)',
    'White and Blue',
    'Special Edition / Christmas'
  ];

  final List<String> _statusOptions = ['Siap Operasi', 'Tidak Siap Operasi'];
  final List<String> _sumberTenagaOptions = [
    'Diesel Elektrik',
    'Diesel Hidrolik',
    'Listrik',
    'Uap'
  ];

  @override
  void initState() {
    super.initState();
    _tipeController =
        TextEditingController(text: widget.lokomotif?.tipeModel ?? '');
    _seriController =
        TextEditingController(text: widget.lokomotif?.seriModel ?? '');
    _keteranganController =
        TextEditingController(text: widget.lokomotif?.keterangan ?? '');

    if (widget.lokomotif != null) {
      _selectedDepoId = widget.lokomotif!.depoId;
      _selectedLivery = _liveryOptions.contains(widget.lokomotif!.livery)
          ? widget.lokomotif!.livery
          : _liveryOptions.first;
      _selectedStatus = _statusOptions.contains(widget.lokomotif!.status)
          ? widget.lokomotif!.status
          : _statusOptions.first;
      _selectedSumberTenaga =
          _sumberTenagaOptions.contains(widget.lokomotif!.sumberTenaga)
              ? widget.lokomotif!.sumberTenaga
              : _sumberTenagaOptions.first;
    }

    _fetchDepos();
  }

  Future<void> _fetchDepos() async {
    try {
      final repository = context.read<LokomotifRepository>();
      final depos = await repository.getDepos();
      setState(() {
        _depoOptions = depos;
        _isLoadingDepos = false;

        // Ensure _selectedDepoId is valid in the loaded options
        if (_selectedDepoId != null &&
            !depos.any((d) => d['depo_id'] == _selectedDepoId)) {
          _selectedDepoId = null;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingDepos = false;
      });
      if (mounted) {
        CustomSnackbar.showError(context, 'Gagal memuat depo: $e');
      }
    }
  }

  @override
  void dispose() {
    _tipeController.dispose();
    _seriController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF153D77).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF153D77), size: 20),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Ambil dari Kamera',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF153D77).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.photo_library_rounded, color: Color(0xFF153D77), size: 20),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Pilih dari Galeri',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDepoId == null || _selectedLivery == null) {
        CustomSnackbar.showError(context, 'Pilih Depo dan Livery terlebih dahulu');
        return;
      }

      final Map<String, dynamic> data = {
        'tipe_model': _tipeController.text,
        'seri_model': _seriController.text,
        'depo_id': _selectedDepoId,
        'livery': _selectedLivery,
        'status': _selectedStatus,
        'sumber_tenaga': _selectedSumberTenaga,
        'keterangan': _keteranganController.text,
      };

      if (_imageFile != null) {
        data['foto'] = await MultipartFile.fromFile(_imageFile!.path,
            filename: 'upload.jpg');
      }

      if (widget.lokomotif == null) {
        context.read<LokomotifBloc>().add(LokomotifCreateRequested(data));
      } else {
        context
            .read<LokomotifBloc>()
            .add(LokomotifUpdateRequested(widget.lokomotif!.id, data));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.lokomotif != null;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<LokomotifBloc, LokomotifState>(
          listener: (context, state) {
            if (state is LokomotifActionSuccess) {
              Navigator.pop(context, true);
            } else if (state is LokomotifError) {
              CustomSnackbar.showError(context, state.message);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFF153D77), size: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEdit
                              ? 'Edit Data Lokomotif'
                              : 'Tambah Sarana Lokomotif',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF153D77)),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 20),
                    child: Text(
                      isEdit
                          ? 'Perbarui informasi jika terdapat kesalahan.'
                          : 'Daftarkan lokomotif baru ke dalam inventaris',
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ),

                  // Divider
                  Container(height: 1, color: const Color(0xFFE2E8F0)),
                  const SizedBox(height: 20),

                  // Image Picker
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      width: double.infinity,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(_imageFile!, fit: BoxFit.cover))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF153D77)
                                            .withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.camera_alt_outlined,
                                      color: Color(0xFF153D77), size: 22),
                                ),
                                const SizedBox(height: 10),
                                const Text('Ketuk untuk ambil foto',
                                    style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Tipe Model'),
                  _buildTextField(_tipeController,
                      'Contoh: CC 201, CC 206, CC 300', Icons.train_outlined),
                  const SizedBox(height: 16),

                  _buildLabel('Seri Model'),
                  _buildTextField(_seriController,
                      'Contoh: 89 01, 78 06, 92 20', Icons.numbers),
                  const SizedBox(height: 16),

                  _buildLabel('Depo Induk'),
                  _isLoadingDepos
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF153D77)))
                      : _buildDepoDropdown(),
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Pilih depot tempat lokomotif ini beroperasi',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFFADB5BD))),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Livery'),
                  _buildDropdown(
                      _selectedLivery,
                      _liveryOptions,
                      'Pilih Livery',
                      Icons.palette_outlined,
                      (val) => setState(() => _selectedLivery = val)),
                  const SizedBox(height: 16),

                  _buildLabel('Sumber Tenaga'),
                  _buildDropdown(
                      _selectedSumberTenaga,
                      _sumberTenagaOptions,
                      'Pilih Sumber Tenaga',
                      Icons.electric_bolt_outlined,
                      (val) => setState(() => _selectedSumberTenaga = val!)),
                  const SizedBox(height: 16),

                  if (isEdit) ...[
                    _buildLabel('Status'),
                    _buildDropdown(
                        _selectedStatus,
                        _statusOptions,
                        'Pilih Status',
                        Icons.info_outline,
                        (val) => setState(() => _selectedStatus = val!)),
                    const SizedBox(height: 16),
                  ],

                  _buildLabel('Keterangan (Opsional)'),
                  TextFormField(
                    controller: _keteranganController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Catatan tambahan mengenai kondisi fisik...',
                      hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Color(0xFF153D77), width: 1.5)),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Divider before actions
                  Container(height: 1, color: const Color(0xFFE2E8F0)),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF153D77),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _submit,
                      child: Text(
                          isEdit ? 'Simpan Perubahan' : 'Simpan Lokomotif',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal',
                          style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF153D77),
              fontWeight: FontWeight.w600,
              fontSize: 13)),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF153D77), width: 1.5)),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
      ),
      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
    );
  }

  Widget _buildDropdown(String? value, List<String> items, String hint,
      IconData icon, Function(String?) onChanged) {
    return DropdownMenu<String>(
      initialSelection: value,
      onSelected: onChanged,
      hintText: hint,
      textStyle: const TextStyle(fontSize: 14),
      leadingIcon: Icon(icon, color: const Color(0xFF94A3B8)),
      trailingIcon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF94A3B8)),
      selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up_rounded,
          color: Color(0xFF153D77)),
      expandedInsets: EdgeInsets.zero,
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(4),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF153D77), width: 1.5)),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dropdownMenuEntries: items
          .map((e) => DropdownMenuEntry<String>(
                value: e,
                label: e,
                style: MenuItemButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDepoDropdown() {
    return DropdownMenu<int>(
      initialSelection: _selectedDepoId,
      onSelected: (val) => setState(() => _selectedDepoId = val),
      hintText: 'Pilih Depo Induk',
      textStyle: const TextStyle(fontSize: 14),
      leadingIcon: const Icon(Icons.business, color: Color(0xFF94A3B8)),
      trailingIcon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF94A3B8)),
      selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up_rounded,
          color: Color(0xFF153D77)),
      expandedInsets: EdgeInsets.zero,
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(4),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF153D77), width: 1.5)),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dropdownMenuEntries: _depoOptions.map((e) {
        return DropdownMenuEntry<int>(
          value: e['depo_id'],
          label: '${e['kode_depo']} - ${e['nama_depo']}',
          style: MenuItemButton.styleFrom(
            foregroundColor: const Color(0xFF334155),
            textStyle: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}
