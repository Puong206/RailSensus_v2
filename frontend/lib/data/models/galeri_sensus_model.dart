import 'package:flutter_dotenv/flutter_dotenv.dart';

class GaleriSensusModel {
  final int id;
  final int sensusId;
  final int userId;
  final String fotoUrl;
  final DateTime ditambahkanPada;
  final String? uploaderName;

  GaleriSensusModel({
    required this.id,
    required this.sensusId,
    required this.userId,
    required this.fotoUrl,
    required this.ditambahkanPada,
    this.uploaderName,
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

  factory GaleriSensusModel.fromJson(Map<String, dynamic> json) {
    return GaleriSensusModel(
      id: json['galeri_id'],
      sensusId: json['sensus_id'],
      userId: json['user_id'],
      fotoUrl: json['foto_url'],
      ditambahkanPada: DateTime.parse(json['ditambahkan_pada']).toLocal(),
      uploaderName: json['uploader']?['username'],
    );
  }
}
