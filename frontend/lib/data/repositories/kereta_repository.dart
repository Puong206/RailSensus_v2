import 'package:dio/dio.dart';
import '../models/kereta_model.dart';
import '../providers/api_provider.dart';

class KeretaRepository {
  final ApiProvider apiProvider;

  KeretaRepository({required this.apiProvider});

  Future<List<KeretaModel>> getAllKereta() async {
    try {
      final response = await apiProvider.dio.get('/kereta');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => KeretaModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load kereta');
    }
  }
}
