import 'dart:io';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../providers/api_provider.dart';
import '../providers/storage_provider.dart';

class AuthRepository {
  final ApiProvider apiProvider;
  final StorageProvider storageProvider;

  AuthRepository({required this.apiProvider, required this.storageProvider});

  Future<UserModel> login(String username, String password) async {
    try {
      final response = await apiProvider.dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        await storageProvider.saveToken(token);
        return UserModel.fromJson(response.data['data']['user']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      } else {
        throw Exception('Login failed: ${e.response?.statusCode} ${e.response?.statusMessage}');
      }
    }
  }

  Future<UserModel> register(String username, String email, String password) async {
    try {
      final response = await apiProvider.dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    await storageProvider.deleteToken();
  }

  Future<bool> hasToken() async {
    final token = await storageProvider.getToken();
    return token != null;
  }

  Future<UserModel> getMe() async {
    try {
      final response = await apiProvider.dio.get('/auth/me');
      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat profil');
    }
  }

  Future<UserModel> updateProfile(String username, String email) async {
    try {
      final response = await apiProvider.dio.put('/auth/profile', data: {
        'username': username,
        'email': email,
      });

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui profil');
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await apiProvider.dio.put('/auth/change-password', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });

      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengubah password');
    }
  }

  Future<UserModel> uploadProfilePhoto(File image) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "foto_profil": await MultipartFile.fromFile(image.path, filename: fileName),
      });

      final response = await apiProvider.dio.post(
        '/auth/profile-photo',
        data: formData,
      );

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengunggah foto profil');
    }
  }

  Future<UserModel> deleteProfilePhoto() async {
    try {
      final response = await apiProvider.dio.delete('/auth/profile-photo');

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus foto profil');
    }
  }

  Future<List<Map<String, dynamic>>> getUserGallery() async {
    try {
      final response = await apiProvider.dio.get('/auth/gallery');

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil galeri foto');
    }
  }
}
