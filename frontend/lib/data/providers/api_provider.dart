import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'storage_provider.dart';

class ApiProvider {
  late Dio _dio;
  final StorageProvider storageProvider;

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  ApiProvider(this.storageProvider) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storageProvider.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle 401 Unauthorized globally if needed
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
