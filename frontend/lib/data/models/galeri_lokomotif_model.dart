import 'package:flutter_dotenv/flutter_dotenv.dart';

class GaleriLokomotifModel {
  final int galeriId;
  final int lokoId;
  final int? userId;
  final String fotoUrl;
  final DateTime? ditambahkanPada;

  GaleriLokomotifModel({
    required this.galeriId,
    required this.lokoId,
    this.userId,
    required this.fotoUrl,
    this.ditambahkanPada,
  });

  String get fullFotoUrl {
    if (fotoUrl.startsWith('http')) return fotoUrl;
    
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    
    final path = fotoUrl.startsWith('/') ? fotoUrl : '/$fotoUrl';
    return '$baseUrl$path';
  }

  factory GaleriLokomotifModel.fromJson(Map<String, dynamic> json) {
    return GaleriLokomotifModel(
      galeriId: json['galeri_id'] is int ? json['galeri_id'] : int.parse(json['galeri_id'].toString()),
      lokoId: json['loko_id'] is int ? json['loko_id'] : int.parse(json['loko_id'].toString()),
      userId: json['user_id'] != null ? (json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString())) : null,
      fotoUrl: json['foto_url'] ?? '',
      ditambahkanPada: json['ditambahkan_pada'] != null 
          ? DateTime.tryParse(json['ditambahkan_pada'].toString())?.toLocal() 
          : null,
    );
  }
}
