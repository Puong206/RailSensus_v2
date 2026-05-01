import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/kereta_model.dart';
import '../models/depo_model.dart';
import '../providers/api_provider.dart';

class AdminMasterRepository {
  final ApiProvider apiProvider;

  AdminMasterRepository({required this.apiProvider});

  // =======================
  // STATS
  // =======================
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await apiProvider.dio.get('/admin/stats');
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat statistik admin');
    }
  }

  // =======================
  // KERETA
  // =======================
  Future<List<KeretaModel>> getKereta({String search = ''}) async {
    try {
      final response = await apiProvider.dio.get('/admin/kereta', queryParameters: {
        'search': search,
      });
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => KeretaModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat kereta');
    }
  }

  Future<KeretaModel> createKereta(Map<String, dynamic> data) async {
    try {
      final response = await apiProvider.dio.post('/admin/kereta', data: data);
      if (response.data['success'] == true) {
        final resData = response.data['data'];
        if (resData is List) {
          return KeretaModel.fromJson(resData.first);
        }
        return KeretaModel.fromJson(resData);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menambahkan kereta');
    }
  }

  Future<KeretaModel> updateKereta(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiProvider.dio.put('/admin/kereta/$id', data: data);
      if (response.data['success'] == true) {
        return KeretaModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui kereta');
    }
  }

  Future<void> deleteKereta(int id) async {
    try {
      final response = await apiProvider.dio.delete('/admin/kereta/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus kereta');
    }
  }

  // =======================
  // DEPO
  // =======================
  Future<List<DepoModel>> getDepo({String search = ''}) async {
    try {
      final response = await apiProvider.dio.get('/admin/depo', queryParameters: {
        'search': search,
      });
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => DepoModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat depo');
    }
  }

  Future<DepoModel> createDepo(Map<String, dynamic> data) async {
    try {
      final response = await apiProvider.dio.post('/admin/depo', data: data);
      if (response.data['success'] == true) {
        return DepoModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menambahkan depo');
    }
  }

  Future<DepoModel> updateDepo(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiProvider.dio.put('/admin/depo/$id', data: data);
      if (response.data['success'] == true) {
        return DepoModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui depo');
    }
  }

  Future<void> deleteDepo(int id) async {
    try {
      final response = await apiProvider.dio.delete('/admin/depo/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus depo');
    }
  }

  // =======================
  // USERS
  // =======================
  Future<List<UserModel>> getUsers({String search = ''}) async {
    try {
      final response = await apiProvider.dio.get('/admin/users', queryParameters: {
        'search': search,
      });
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => UserModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat users');
    }
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiProvider.dio.put('/admin/users/$id', data: data);
      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui user');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final response = await apiProvider.dio.delete('/admin/users/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus user');
    }
  }
}
