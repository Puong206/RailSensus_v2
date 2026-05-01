import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'galeri_sensus_model.dart';

class SensusModel {
  final int id;
  final int userId;
  final int lokoId;
  final int kaId;
  final double trustScore;
  final String? lokasi;
  final String? fotoBukti;
  final DateTime waktuSensus;

  // Joined fields from API
  final String? username;
  final String? userRole;
  final String? userFotoProfil;
  final String? nomorSeriLokomotif;
  final String? namaKa;
  final String? nomorKa;
  
  final int totalValid;
  final int totalInvalid;
  final String? userVote;
  
  // Gallery
  final List<GaleriSensusModel> galeri;

  SensusModel({
    required this.id,
    required this.userId,
    required this.lokoId,
    required this.kaId,
    required this.trustScore,
    this.lokasi,
    this.fotoBukti,
    required this.waktuSensus,
    this.username,
    this.userRole,
    this.userFotoProfil,
    this.nomorSeriLokomotif,
    this.namaKa,
    this.nomorKa,
    this.totalValid = 0,
    this.totalInvalid = 0,
    this.userVote,
    this.galeri = const [],
  });

  String? get fullFotoBuktiUrl {
    if (fotoBukti == null || fotoBukti!.isEmpty) return null;
    if (fotoBukti!.startsWith('http')) return fotoBukti;
    
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    
    final path = fotoBukti!.startsWith('/') ? fotoBukti! : '/$fotoBukti';
    return '$baseUrl$path';
  }

  String? get fullUserFotoProfilUrl {
    if (userFotoProfil == null || userFotoProfil!.isEmpty) return null;
    if (userFotoProfil!.startsWith('http')) return userFotoProfil;
    
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    
    final path = userFotoProfil!.startsWith('/') ? userFotoProfil! : '/$userFotoProfil';
    return '$baseUrl$path';
  }

  factory SensusModel.fromJson(Map<String, dynamic> json) {
    return SensusModel(
      id: json['sensus_id'],
      userId: json['user_id'],
      lokoId: json['loko_id'],
      kaId: json['ka_id'],
      trustScore: (json['trust_score'] ?? 0).toDouble(),
      lokasi: json['lokasi'],
      fotoBukti: json['foto_bukti'],
      waktuSensus: DateTime.parse(json['waktu_sensus']).toLocal(),
      username: json['User']?['username'],
      userRole: json['User']?['role'],
      userFotoProfil: json['User']?['foto_profil'],
      nomorSeriLokomotif: json['Lokomotif'] != null 
          ? '${json['Lokomotif']['tipe_model']} ${json['Lokomotif']['seri_model']}'
          : null,
      namaKa: json['Kereta']?['nama_ka'] ?? json['Keretum']?['nama_ka'],
      nomorKa: json['Kereta']?['nomor_ka'] ?? json['Keretum']?['nomor_ka'],
      totalValid: json['total_valid'] ?? 0,
      totalInvalid: json['total_invalid'] ?? 0,
      userVote: json['user_vote'],
      galeri: json['GaleriSensus'] != null 
          ? (json['GaleriSensus'] as List).map((i) => GaleriSensusModel.fromJson(i)).toList()
          : [],
    );
  }
}
