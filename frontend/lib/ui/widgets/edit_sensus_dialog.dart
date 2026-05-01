import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/lokomotif_model.dart';
import '../../../data/models/kereta_model.dart';
import '../../../data/models/sensus_model.dart';
import '../../../data/repositories/lokomotif_repository.dart';
import '../../../data/repositories/kereta_repository.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/storage_provider.dart';
import '../../logic/bloc/sensus/sensus_bloc.dart';
import '../../logic/bloc/sensus/sensus_event.dart';

class EditSensusDialog extends StatefulWidget {
  final SensusModel sensus;
  const EditSensusDialog({super.key, required this.sensus});

  @override
  State<EditSensusDialog> createState() => _EditSensusDialogState();
}

class _EditSensusDialogState extends State<EditSensusDialog> {
  final _formKey = GlobalKey<FormState>();
  
  LokomotifModel? _selectedLokomotif;
  KeretaModel? _selectedKereta;
  String? _selectedNamaKereta;

  List<LokomotifModel> _lokomotifs = [];
  List<KeretaModel> _keretas = [];
  List<String> _namaKeretas = [];
  List<KeretaModel> _filteredKeretasByNama = [];

  bool _isLoading = true;
  bool _isSubmitting = false;

  late LokomotifRepository _lokoRepo;
  late KeretaRepository _keretaRepo;


  @override
  void initState() {
    super.initState();
    final apiProvider = ApiProvider(StorageProvider());
    _lokoRepo = LokomotifRepository(apiProvider: apiProvider);
    _keretaRepo = KeretaRepository(apiProvider: apiProvider);

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final lokoResponse = await _lokoRepo.getLokomotifList(page: 1, limit: 1000);
      final keretaData = await _keretaRepo.getAllKereta();
      final uniqueNama = keretaData.map((k) => k.namaKa).toSet().toList();
      uniqueNama.sort();

      setState(() {
        _lokomotifs = lokoResponse['list'];
        _keretas = keretaData;
        _namaKeretas = uniqueNama;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    final data = <String, dynamic>{};
    if (_selectedLokomotif != null) data['loko_id'] = _selectedLokomotif!.id;
    if (_selectedKereta != null) data['ka_id'] = _selectedKereta!.id;

    context.read<SensusBloc>().add(SensusUpdateRequested(widget.sensus.id, data));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(
                color: Color(0xFF153D77),
              ),
              SizedBox(height: 16),
              Text(
                'Memuat Data...',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              )
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Edit Data Sensus',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lokomotif Baru (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 13, fontFamily: 'Plus Jakarta Sans')),
                      const SizedBox(height: 8),
                      DropdownMenu<LokomotifModel>(
                        expandedInsets: EdgeInsets.zero,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        menuHeight: 250,
                        hintText: 'Cari lokomotif...',
                        textStyle: const TextStyle(fontSize: 14, fontFamily: 'Plus Jakarta Sans', color: Color(0xFF1E293B)),
                        inputDecorationTheme: InputDecorationTheme(
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF153D77), width: 1.5)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        menuStyle: MenuStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          elevation: MaterialStateProperty.all(4),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                        dropdownMenuEntries: _lokomotifs.map((loko) {
                          return DropdownMenuEntry<LokomotifModel>(
                            value: loko,
                            label: '${loko.tipeModel} ${loko.seriModel}',
                            style: MenuItemButton.styleFrom(
                              foregroundColor: const Color(0xFF1E293B),
                              textStyle: const TextStyle(fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
                            ),
                          );
                        }).toList(),
                        onSelected: (value) => setState(() => _selectedLokomotif = value),
                      ),
                      const SizedBox(height: 16),
                      const Text('Nama Kereta Baru (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 13, fontFamily: 'Plus Jakarta Sans')),
                      const SizedBox(height: 8),
                      DropdownMenu<String>(
                        expandedInsets: EdgeInsets.zero,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        menuHeight: 250,
                        hintText: 'Cari nama kereta...',
                        textStyle: const TextStyle(fontSize: 14, fontFamily: 'Plus Jakarta Sans', color: Color(0xFF1E293B)),
                        inputDecorationTheme: InputDecorationTheme(
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF153D77), width: 1.5)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        menuStyle: MenuStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          elevation: MaterialStateProperty.all(4),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                        dropdownMenuEntries: _namaKeretas.map((nama) {
                          return DropdownMenuEntry<String>(
                            value: nama,
                            label: nama,
                            style: MenuItemButton.styleFrom(
                              foregroundColor: const Color(0xFF1E293B),
                              textStyle: const TextStyle(fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
                            ),
                          );
                        }).toList(),
                        onSelected: (value) {
                          setState(() {
                            _selectedNamaKereta = value;
                            _selectedKereta = null;
                            if (value != null) {
                              _filteredKeretasByNama = _keretas.where((ka) => ka.namaKa == value).toList();
                            } else {
                              _filteredKeretasByNama = [];
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_selectedNamaKereta != null) ...[
                        const Text('Nomor Kereta Baru', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 13, fontFamily: 'Plus Jakarta Sans')),
                        const SizedBox(height: 8),
                        DropdownMenu<KeretaModel>(
                          key: ValueKey(_selectedNamaKereta),
                          expandedInsets: EdgeInsets.zero,
                          enableFilter: true,
                          requestFocusOnTap: true,
                          menuHeight: 250,
                          hintText: 'Cari nomor kereta...',
                          textStyle: const TextStyle(fontSize: 14, fontFamily: 'Plus Jakarta Sans', color: Color(0xFF1E293B)),
                          inputDecorationTheme: InputDecorationTheme(
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF153D77), width: 1.5)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          menuStyle: MenuStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.white),
                            elevation: MaterialStateProperty.all(4),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          ),
                          dropdownMenuEntries: _filteredKeretasByNama.map((ka) {
                            return DropdownMenuEntry<KeretaModel>(
                              value: ka,
                              label: ka.nomorKa,
                              style: MenuItemButton.styleFrom(
                                foregroundColor: const Color(0xFF1E293B),
                                textStyle: const TextStyle(fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
                              ),
                            );
                          }).toList(),
                          onSelected: (value) => setState(() => _selectedKereta = value),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      elevation: 0,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF153D77),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Simpan',
                            style: TextStyle(
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
  }
}
