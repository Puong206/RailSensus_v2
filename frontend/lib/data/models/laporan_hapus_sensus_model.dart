class LaporanHapusSensusModel {
  final int laporanId;
  final int? sensusId;
  final int userId;
  final String alasanHapus;
  final String statusLaporan; // 'Menunggu', 'Disetujui', 'Ditolak'
  final DateTime? dilaporkanPada;

  // Optional nested data
  final Map<String, dynamic>? sensus;
  final Map<String, dynamic>? pelapor;

  LaporanHapusSensusModel({
    required this.laporanId,
    required this.sensusId,
    required this.userId,
    required this.alasanHapus,
    required this.statusLaporan,
    this.dilaporkanPada,
    this.sensus,
    this.pelapor,
  });

  factory LaporanHapusSensusModel.fromJson(Map<String, dynamic> json) {
    return LaporanHapusSensusModel(
      laporanId: json['laporan_id'] is int
          ? json['laporan_id']
          : int.parse(json['laporan_id'].toString()),
      sensusId: json['sensus_id'] != null
          ? (json['sensus_id'] is int
              ? json['sensus_id']
              : int.tryParse(json['sensus_id'].toString()))
          : null,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      alasanHapus: json['alasan_hapus'] ?? '',
      statusLaporan: json['status_laporan'] ?? 'Menunggu',
      dilaporkanPada: json['dilaporkan_pada'] != null
          ? DateTime.tryParse(json['dilaporkan_pada'])
          : null,
      sensus: json['sensus'] as Map<String, dynamic>?,
      pelapor: json['pelapor'] as Map<String, dynamic>?,
    );
  }
}
