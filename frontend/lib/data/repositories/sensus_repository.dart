import 'package:dio/dio.dart';
import '../models/sensus_model.dart';
import '../providers/api_provider.dart';

class SensusRepository {
  final ApiProvider apiProvider;

  SensusRepository({required this.apiProvider});

  Future<Map<String, dynamic>> getSensusFeed({int page = 1, int limit = 10, String search = ''}) async {
    try {
      final response = await apiProvider.dio.get('/sensus', queryParameters: {
        'page': page,
        'limit': limit,
        if (search.isNotEmpty) 'search': search,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['data'];
        final totalPages = response.data['data']['totalPages'];
        final totalItems = response.data['data']['totalItems'];
        final currentPage = response.data['data']['currentPage'];
        final List<SensusModel> list = data.map((e) => SensusModel.fromJson(e)).toList();
        return {
          'list': list,
          'totalPages': totalPages,
          'totalItems': totalItems,
          'currentPage': currentPage,
        };
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load sensus feed');
    }
  }

  Future<SensusModel> getSensusById(int id) async {
    try {
      final response = await apiProvider.dio.get('/sensus/$id');
      if (response.data['success'] == true) {
        return SensusModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load sensus detail');
    }
  }

  Future<SensusModel> createSensus(FormData data) async {
    try {
      final response = await apiProvider.dio.post(
        '/sensus',
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.data['success'] == true) {
        return SensusModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create sensus');
    }
  }

  Future<void> voteSensus(int sensusId, String tipeVote) async {
    try {
      final response = await apiProvider.dio.post('/sensus/$sensusId/vote', data: {
        'tipe_vote': tipeVote,
      });
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to vote');
    }
  }

  Future<void> addGalleryPhoto(int sensusId, FormData data) async {
    try {
      final response = await apiProvider.dio.post(
        '/sensus/$sensusId/galeri',
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to upload photo');
    }
  }

  Future<void> updateSensus(int sensusId, Map<String, dynamic> data) async {
    try {
      final response = await apiProvider.dio.put('/sensus/$sensusId', data: data);
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update sensus');
    }
  }

  Future<void> deleteSensus(int sensusId) async {
    try {
      final response = await apiProvider.dio.delete('/sensus/$sensusId');
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete sensus');
    }
  }

  Future<void> deleteGaleriPhoto(int galeriId) async {
    try {
      final response = await apiProvider.dio.delete('/sensus/galeri/$galeriId');
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete photo');
    }
  }
}
