import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';

/// Secure storage service provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Dio HTTP client provider
final dioProvider = Provider<Dio>((ref) {
  final storageService = ref.watch(secureStorageProvider);
  return DioClient(storageService).dio;
});
