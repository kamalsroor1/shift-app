import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/core_providers.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MarketplaceRepository(dio);
});

class MarketplaceRepository {
  final Dio _dio;

  MarketplaceRepository(this._dio);

  Future<List<Map<String, dynamic>>> getAvailableListings() async {
    try {
      final response = await _dio.get(ApiConstants.marketplace);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List ? response.data : (response.data['items'] ?? []);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> createSwapRequest(int targetScheduleId, String reason) async {
    try {
      final response = await _dio.post(
        ApiConstants.swaps,
        data: {'target_schedule_id': targetScheduleId, 'reason': reason},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw ApiException('فشل إنشاء طلب التبادل.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
