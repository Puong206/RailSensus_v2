import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'galeri_lokomotif_model.dart';

class LokomotifModel {
  final int id;
  final String tipeModel;
  final String seriModel;
  final int? depoId;
  final String depoName;
  final String livery;
  final String? keterangan;
  final String? fotoUrl;
  final String status;
  final String sumberTenaga;
  final int? createdBy;
  final String? creatorName;
  final String? creatorFoto;
  final List<GaleriLokomotifModel> galeri;

  LokomotifModel({
    required this.id,
    required this.tipeModel,
    required this.seriModel,
    this.depoId,
    required this.depoName,
    required this.livery,
    this.keterangan,
    this.fotoUrl,
    required this.status,
    required this.sumberTenaga,
    this.createdBy,
    this.creatorName,
    this.creatorFoto,
    this.galeri = const [],
  });

  String? get fullFotoUrl {
    if (fotoUrl == null || fotoUrl!.isEmpty) return null;
    if (fotoUrl!.startsWith('http')) return fotoUrl;
    
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';
    // Remove the '/api' suffix to get the host url for static files
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    
    // Ensure fotoUrl starts with a slash
    final path = fotoUrl!.startsWith('/') ? fotoUrl! : '/$fotoUrl';
    return '$baseUrl$path';
  }

  String? get fullCreatorFotoUrl {
    if (creatorFoto == null || creatorFoto!.isEmpty) return null;
    if (creatorFoto!.startsWith('http')) return creatorFoto;
    
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    
    final path = creatorFoto!.startsWith('/') ? creatorFoto! : '/$creatorFoto';
    return '$baseUrl$path';
  }

  factory LokomotifModel.fromJson(Map<String, dynamic> json) {
    return LokomotifModel(
      id: json['loko_id'],
      tipeModel: json['tipe_model'] ?? '',
      seriModel: json['seri_model'] ?? '',
      depoId: json['depo_id'],
      depoName: json['depo'] != null ? json['depo']['nama_depo'] : '-',
      livery: json['livery'] ?? '',
      keterangan: json['keterangan'],
      fotoUrl: json['foto_url'],
      status: json['status'] ?? 'Siap Operasi',
      sumberTenaga: json['sumber_tenaga'] ?? 'Diesel Elektrik',
      createdBy: json['created_by'] != null ? int.tryParse(json['created_by'].toString()) : null,
      creatorName: json['creator'] != null ? json['creator']['username'] : null,
      creatorFoto: json['creator'] != null ? json['creator']['foto_profil'] : null,
      galeri: json['galeri'] != null 
          ? (json['galeri'] as List).map((i) => GaleriLokomotifModel.fromJson(i)).toList() 
          : [],
    );
  }
}
