import 'package:dio/dio.dart';
import '../models/laporan_hapus_model.dart';
import '../providers/api_provider.dart';

class LaporanHapusRepository {
  final ApiProvider apiProvider;

  LaporanHapusRepository({required this.apiProvider});

  /// User: Kirim laporan permintaan penghapusan lokomotif
  Future<LaporanHapusModel> createLaporan(int lokoId, String alasan) async {
    try {
      final response = await apiProvider.dio.post(
        '/laporan-hapus/$lokoId',
        data: {'alasan_hapus': alasan},
      );
      if (response.data['success'] == true) {
        return LaporanHapusModel.fromJson(response.data['data']);
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
        '/laporan-hapus',
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
          'list': data.map((e) => LaporanHapusModel.fromJson(e)).toList(),
          'totalItems': totalItems,
          'totalPages': totalPages,
        };
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal memuat laporan');
    }
  }

  /// Admin: Setujui laporan (lokomotif langsung dihapus)
  Future<void> setujuiLaporan(int laporanId) async {
    try {
      final response =
          await apiProvider.dio.put('/laporan-hapus/$laporanId/setujui');
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
          await apiProvider.dio.put('/laporan-hapus/$laporanId/tolak');
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal menolak laporan');
    }
  }

  /// Admin: Bersihkan riwayat laporan
  Future<void> clearHistory(String status) async {
    try {
      final response = await apiProvider.dio.delete(
        '/laporan-hapus/history',
        queryParameters: {'status': status},
      );
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal membersihkan riwayat');
    }
  }
}
