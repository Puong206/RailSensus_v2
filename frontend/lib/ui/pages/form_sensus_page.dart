import '../widgets/custom_snackbar.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/lokomotif_model.dart';
import '../../../data/models/kereta_model.dart';
import '../../../data/repositories/lokomotif_repository.dart';
import '../../../data/repositories/kereta_repository.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/storage_provider.dart';
import '../../logic/bloc/sensus/sensus_bloc.dart';
import '../../logic/bloc/sensus/sensus_event.dart';
import '../../logic/bloc/sensus/sensus_state.dart';

class FormSensusPage extends StatefulWidget {
  const FormSensusPage({super.key});

  @override
  State<FormSensusPage> createState() => _FormSensusPageState();
}

class _FormSensusPageState extends State<FormSensusPage> {
  final _formKey = GlobalKey<FormState>();

  LokomotifModel? _selectedLokomotif;
  KeretaModel? _selectedKereta;
  String? _selectedNamaKereta;

  List<LokomotifModel> _lokomotifs = [];
  List<KeretaModel> _keretas = [];
  List<String> _namaKeretas = [];
  List<KeretaModel> _filteredKeretasByNama = [];

  File? _imageFile;
  Position? _currentPosition;

  bool _isLoadingData = true;
  bool _isGettingLocation = false;
  bool _isSubmitting = false;

  late LokomotifRepository _lokoRepo;
  late KeretaRepository _keretaRepo;

  @override
  void initState() {
    super.initState();
    final apiProvider = ApiProvider(StorageProvider());
    _lokoRepo = LokomotifRepository(apiProvider: apiProvider);
    _keretaRepo = KeretaRepository(apiProvider: apiProvider);

    _loadInitialData();
    _determinePosition();
  }

  Future<void> _loadInitialData() async {
    try {
      final keretaData = await _keretaRepo.getAllKereta();
      final uniqueNama = keretaData.map((k) => k.namaKa).toSet().toList();
      uniqueNama.sort();

      setState(() {
        _keretas = keretaData;
        _namaKeretas = uniqueNama;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        CustomSnackbar.showError(context, 'Gagal memuat data: $e');
      }
    }
  }

  Future<void> _determinePosition() async {
    setState(() => _isGettingLocation = true);

    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() => _isGettingLocation = false);
      if (mounted) {
        CustomSnackbar.showError(context, 'Gagal mengambil lokasi: $e');
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLokomotif == null || _selectedKereta == null) {
      CustomSnackbar.showSuccess(context, 'Pilih Lokomotif dan Kereta terlebih dahulu');
      return;
    }

    if (_currentPosition == null) {
      CustomSnackbar.showSuccess(context, 
                'Lokasi belum didapatkan. Harap tunggu atau pastikan GPS menyala.');
      return;
    }

    setState(() => _isSubmitting = true);

    final formData = FormData.fromMap({
      'loko_id': _selectedLokomotif!.id,
      'ka_id': _selectedKereta!.id,
      'latitude': _currentPosition!.latitude,
      'longitude': _currentPosition!.longitude,
    });

    if (_imageFile != null) {
      formData.files.add(MapEntry(
        'foto_bukti',
        MultipartFile.fromFileSync(_imageFile!.path,
            filename: _imageFile!.path.split('/').last),
      ));
    } else if (_selectedLokomotif!.fotoUrl != null && _selectedLokomotif!.fotoUrl!.isNotEmpty) {
      formData.fields.add(MapEntry('foto_bukti', _selectedLokomotif!.fotoUrl!));
    }

    context.read<SensusBloc>().add(SensusCreateRequested(formData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<SensusBloc, SensusState>(
          listener: (context, state) {
            if (state is SensusActionSuccess) {
              setState(() => _isSubmitting = false);
              CustomSnackbar.showSuccess(context, 'Sensus berhasil ditambahkan!');
              context.pop();
            } else if (state is SensusError) {
              setState(() => _isSubmitting = false);
              CustomSnackbar.showSuccess(context, state.message);
            }
          },
          child: _isLoadingData
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF153D77)))
              : SingleChildScrollView(
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
                              onTap: () => context.pop(),
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
                            const Expanded(
                              child: Text(
                                'Tambah Sensus',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF153D77)),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 6, bottom: 20),
                          child: Text('Laporkan data lokomotif yang Anda temui',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                        ),

                        // Divider
                        Container(height: 1, color: const Color(0xFFE2E8F0)),
                        const SizedBox(height: 20),

                        // Lokomotif Dropdown
                        _buildLabel('Lokomotif'),
                        Autocomplete<LokomotifModel>(
                          displayStringForOption: (option) =>
                              '${option.tipeModel} ${option.seriModel}',
                          optionsBuilder: (TextEditingValue textEditingValue) async {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<LokomotifModel>.empty();
                            }
                            try {
                              final response = await _lokoRepo.getLokomotifList(
                                page: 1,
                                limit: 10,
                                search: textEditingValue.text,
                              );
                              final List<LokomotifModel> results = response['list'];
                              return results.where((l) => l.status == 'Siap Operasi');
                            } catch (e) {
                              return const Iterable<LokomotifModel>.empty();
                            }
                          },
                          onSelected: (LokomotifModel selection) {
                            setState(() {
                              _selectedLokomotif = selection;
                            });
                          },
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'Cari Lokomotif...',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                prefixIcon: const Icon(Icons.train_outlined, color: Color(0xFF94A3B8)),
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
                                suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                              ),
                              validator: (value) {
                                if (_selectedLokomotif == null)
                                  return 'Pilih lokomotif dari daftar';
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Nama Kereta Dropdown
                        _buildLabel('Nama Kereta Api'),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return _namaKeretas;
                            }
                            return _namaKeretas.where((nama) => nama
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (String selection) {
                            setState(() {
                              _selectedNamaKereta = selection;
                              _selectedKereta = null;
                              _filteredKeretasByNama = _keretas
                                  .where((ka) => ka.namaKa == selection)
                                  .toList();
                            });
                          },
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'Cari Nama Kereta...',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                prefixIcon: const Icon(Icons.directions_subway_outlined, color: Color(0xFF94A3B8)),
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
                                suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                              ),
                              validator: (value) {
                                if (_selectedNamaKereta == null) {
                                  return 'Pilih nama kereta dari daftar';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Nomor Kereta Dropdown
                        if (_selectedNamaKereta != null) ...[
                          _buildLabel('Nomor Kereta Api'),
                          Autocomplete<KeretaModel>(
                            key: ValueKey(_selectedNamaKereta),
                            displayStringForOption: (option) => option.nomorKa,
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return _filteredKeretasByNama;
                              }
                              return _filteredKeretasByNama.where((ka) => ka.nomorKa
                                  .toLowerCase()
                                  .contains(textEditingValue.text.toLowerCase()));
                            },
                            onSelected: (KeretaModel selection) {
                              setState(() {
                                _selectedKereta = selection;
                              });
                            },
                            fieldViewBuilder: (context, textEditingController,
                                focusNode, onFieldSubmitted) {
                              return TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: 'Pilih Nomor Kereta...',
                                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                  prefixIcon: const Icon(Icons.numbers, color: Color(0xFF94A3B8)),
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
                                  suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                                ),
                                validator: (value) {
                                  if (_selectedKereta == null) {
                                    return 'Pilih nomor kereta dari daftar';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Location Info
                        _buildLabel('Lokasi Sensus'),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF153D77).withOpacity(0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.location_on_outlined,
                                    color: Color(0xFF153D77), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _isGettingLocation
                                    ? const Text('Mengambil lokasi GPS...', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13))
                                    : _currentPosition != null
                                        ? Text(
                                            '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                            style: const TextStyle(color: Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w500))
                                        : const Text('Lokasi belum ditemukan',
                                            style: TextStyle(color: Colors.red, fontSize: 13)),
                              ),
                              if (!_isGettingLocation)
                                GestureDetector(
                                  onTap: _determinePosition,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.refresh_rounded,
                                        color: Color(0xFF153D77), size: 18),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Foto Bukti
                        _buildLabel('Foto Bukti (Opsional)'),
                        GestureDetector(
                          onTap: () {
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
                          },
                          child: Container(
                            width: double.infinity,
                            height: 110,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: _imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(_imageFile!,
                                        fit: BoxFit.cover),
                                  )
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
                                              color: const Color(0xFF153D77).withOpacity(0.08),
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

                        const SizedBox(height: 28),

                        // Divider before action
                        Container(height: 1, color: const Color(0xFFE2E8F0)),
                        const SizedBox(height: 20),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF153D77),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Kirim Sensus',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: const Text('Batal',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
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
}
