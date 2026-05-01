import 'package:dio/dio.dart';
import '../models/lokomotif_model.dart';
import '../models/galeri_lokomotif_model.dart';
import '../providers/api_provider.dart';

class LokomotifRepository {
  final ApiProvider apiProvider;

  LokomotifRepository({required this.apiProvider});

  Future<Map<String, dynamic>> getLokomotifList({int page = 1, int limit = 10, String search = ''}) async {
    try {
      final response = await apiProvider.dio.get('/lokomotif', queryParameters: {
        'page': page,
        'limit': limit,
        'search': search,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['data'];
        final totalPages = response.data['data']['totalPages'] ?? 1;
        final totalItems = response.data['data']['totalItems'] ?? 0;
        final List<LokomotifModel> list = data.map((e) => LokomotifModel.fromJson(e)).toList();
        return {'list': list, 'totalPages': totalPages, 'totalItems': totalItems};
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load data');
    }
  }

  Future<LokomotifModel> getLokomotifById(int id) async {
    try {
      final response = await apiProvider.dio.get('/lokomotif/$id');
      if (response.data['success'] == true) {
        return LokomotifModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load lokomotif');
    }
  }

  Future<LokomotifModel> createLokomotif(Map<String, dynamic> data) async {
    try {
      FormData formData = FormData.fromMap(data);
      final response = await apiProvider.dio.post('/lokomotif', data: formData);
      if (response.data['success'] == true) {
        return LokomotifModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menambahkan lokomotif');
    }
  }

  Future<LokomotifModel> updateLokomotif(int id, Map<String, dynamic> data) async {
    try {
      FormData formData = FormData.fromMap(data);
      final response = await apiProvider.dio.put('/lokomotif/$id', data: formData);
      if (response.data['success'] == true) {
        return LokomotifModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui lokomotif');
    }
  }

  Future<void> deleteLokomotif(int id) async {
    try {
      final response = await apiProvider.dio.delete('/lokomotif/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus lokomotif');
    }
  }

  Future<List<Map<String, dynamic>>> getDepos() async {
    try {
      final response = await apiProvider.dio.get('/depo');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat depo');
    }
  }

  Future<GaleriLokomotifModel> uploadGaleriPhoto(int lokoId, String imagePath) async {
    try {
      FormData formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(imagePath, filename: 'galeri_upload.jpg')
      });
      final response = await apiProvider.dio.post('/lokomotif/$lokoId/galeri', data: formData);
      if (response.data['success'] == true) {
        return GaleriLokomotifModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengunggah foto ke galeri');
    }
  }

  Future<void> deleteGaleriPhoto(int galeriId) async {
    try {
      final response = await apiProvider.dio.delete('/lokomotif/galeri/$galeriId');
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus foto galeri');
    }
  }
}
