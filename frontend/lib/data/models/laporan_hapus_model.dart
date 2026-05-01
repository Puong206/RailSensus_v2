class LaporanHapusModel {
  final int laporanId;
  final int? lokoId;
  final int userId;
  final String alasanHapus;
  final String statusLaporan; // 'Menunggu', 'Disetujui', 'Ditolak'
  final DateTime? dilaporkanPada;

  // Optional nested data
  final Map<String, dynamic>? lokomotif;
  final Map<String, dynamic>? pelapor;

  LaporanHapusModel({
    required this.laporanId,
    required this.lokoId,
    required this.userId,
    required this.alasanHapus,
    required this.statusLaporan,
    this.dilaporkanPada,
    this.lokomotif,
    this.pelapor,
  });

  factory LaporanHapusModel.fromJson(Map<String, dynamic> json) {
    return LaporanHapusModel(
      laporanId: json['laporan_id'] is int
          ? json['laporan_id']
          : int.parse(json['laporan_id'].toString()),
      lokoId: json['loko_id'] != null
          ? (json['loko_id'] is int
              ? json['loko_id']
              : int.tryParse(json['loko_id'].toString()))
          : null,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      alasanHapus: json['alasan_hapus'] ?? '',
      statusLaporan: json['status_laporan'] ?? 'Menunggu',
      dilaporkanPada: json['dilaporkan_pada'] != null
          ? DateTime.tryParse(json['dilaporkan_pada'])
          : null,
      lokomotif: json['lokomotif'] as Map<String, dynamic>?,
      pelapor: json['pelapor'] as Map<String, dynamic>?,
    );
  }
}
