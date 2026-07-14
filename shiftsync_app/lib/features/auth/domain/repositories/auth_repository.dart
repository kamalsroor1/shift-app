import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/local_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(dio, storage);
});

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthRepository(this._dio, this._storage);

  /// Authenticate nurse/doctor using phone number and password via OAuth2 form payload or JSON
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        // FastAPI OAuth2PasswordRequestForm expects username/password as form data or JSON depending on endpoint setup
        data: {
          'username': phone,
          'password': password,
          'phone': phone,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'] ?? '';
        final userId = response.data['user_id']?.toString() ?? '1';

        await _storage.saveTokenPair(accessToken, refreshToken);
        await _storage.saveUserInfo(phone, userId);

        return response.data;
      }
      throw ApiException('فشل تسجيل الدخول. تأكد من صحة البيانات.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    await HiveCacheService.clearCache();
  }
}
