import 'package:dio/dio.dart';
import '../models/laporan_hapus_sensus_model.dart';
import '../providers/api_provider.dart';

class LaporanHapusSensusRepository {
  final ApiProvider apiProvider;

  LaporanHapusSensusRepository({required this.apiProvider});

  /// User: Kirim laporan permintaan penghapusan sensus
  Future<LaporanHapusSensusModel> createLaporan(int sensusId, String alasan) async {
    try {
      final response = await apiProvider.dio.post(
        '/laporan-hapus-sensus/$sensusId',
        data: {'alasan_hapus': alasan},
      );
      if (response.data['success'] == true) {
        return LaporanHapusSensusModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal mengirim laporan penghapusan');
    }
  }

  /// Admin: Ambil semua laporan (opsional filter status)
  Future<Map<String, dynamic>> getAllLaporan({String? status, int page = 1, int limit = 10}) async {
    try {
      final response = await apiProvider.dio.get(
        '/laporan-hapus-sensus',
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'limit': limit,
        },
      );
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['data'];
        final totalItems = response.data['data']['totalItems'];
        final totalPages = response.data['data']['totalPages'];
        return {
          'list': data.map((e) => LaporanHapusSensusModel.fromJson(e)).toList(),
          'totalItems': totalItems,
          'totalPages': totalPages,
        };
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal memuat laporan sensus');
    }
  }

  /// Admin: Setujui laporan (sensus langsung dihapus)
  Future<void> setujuiLaporan(int laporanId) async {
    try {
      final response =
          await apiProvider.dio.put('/laporan-hapus-sensus/$laporanId/setujui');
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal menyetujui laporan');
    }
  }

  /// Admin: Tolak laporan
  Future<void> tolakLaporan(int laporanId) async {
    try {
      final response =
          await apiProvider.dio.put('/laporan-hapus-sensus/$laporanId/tolak');
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal menolak laporan sensus');
    }
  }

  /// Admin: Bersihkan riwayat laporan
  Future<void> clearHistory(String status) async {
    try {
      final response = await apiProvider.dio.delete(
        '/laporan-hapus-sensus/history',
        queryParameters: {'status': status},
      );
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal membersihkan riwayat sensus');
    }
  }
}
