import 'package:dio/dio.dart';
import '../storage/local_storage.dart';
import 'api_constants.dart';

/// DioClient — Configures HTTP timeouts, base URL, and JWT Authorization interceptor.
class DioClient {
  late final Dio _dio;
  final SecureStorageService _storageService;

  DioClient(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Do not attach token for login or refresh requests
          if (options.path != ApiConstants.login && options.path != ApiConstants.refresh) {
            final token = await _storageService.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Handle automatic token refresh if 401 occurs
          if (error.response?.statusCode == 401 && error.requestOptions.path != ApiConstants.login) {
            final refreshToken = await _storageService.getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
                final response = await refreshDio.post(
                  ApiConstants.refresh,
                  data: {'refresh_token': refreshToken},
                );

                if (response.statusCode == 200 && response.data != null) {
                  final newAccess = response.data['access_token'];
                  final newRefresh = response.data['refresh_token'] ?? refreshToken;
                  await _storageService.saveTokenPair(newAccess, newRefresh);

                  // Retry the original failed request with the new access token
                  error.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                  final cloneResponse = await _dio.fetch(error.requestOptions);
                  return handler.resolve(cloneResponse);
                }
              } catch (_) {
                // Refresh failed, clear storage so user is redirected to login
                await _storageService.clearAll();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
