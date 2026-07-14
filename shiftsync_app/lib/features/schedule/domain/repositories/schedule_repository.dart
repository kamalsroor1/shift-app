import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/widgets/shift_badge.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ScheduleRepository(dio);
});

class ScheduleRepository {
  final Dio _dio;

  ScheduleRepository(this._dio);

  /// Fetch monthly schedules from real FastAPI backend or fallback to Hive cache when offline
  Future<Map<DateTime, ShiftType>> getMonthlySchedule(int year, int month) async {
    final cacheKey = 'schedule_${year}_$month';
    final box = HiveCacheService.getScheduleBox();

    try {
      final response = await _dio.get(
        ApiConstants.schedules,
        queryParameters: {'year': year, 'month': month},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> rawList = response.data is List ? response.data : (response.data['items'] ?? []);
        final Map<DateTime, ShiftType> scheduleMap = {};

        for (var item in rawList) {
          final dateStr = item['shift_date'] ?? item['date'];
          final typeStr = item['shift_type'] ?? item['type'];
          if (dateStr != null && typeStr != null) {
            final date = DateTime.parse(dateStr.toString());
            final normalized = DateTime(date.year, date.month, date.day);
            scheduleMap[normalized] = _parseShiftType(typeStr.toString());
          }
        }

        // Cache exact serialized string to Hive for offline reads
        final Map<String, String> cacheMap = {};
        scheduleMap.forEach((key, value) {
          cacheMap[DateFormat('yyyy-MM-dd').format(key)] = value.name;
        });
        await box.put(cacheKey, jsonEncode(cacheMap));

        return scheduleMap;
      }
      throw ApiException('فشل في جلب جدول الورديات من الخادم.');
    } on DioException catch (e) {
      // 404 simply means no schedule items generated/found for this month yet
      if (e.response?.statusCode == 404) {
        return {};
      }
      // Offline fallback: check if we have last-known schedules cached in Hive
      if (box.containsKey(cacheKey)) {
        try {
          final String cachedJson = box.get(cacheKey);
          final Map<String, dynamic> decoded = jsonDecode(cachedJson);
          final Map<DateTime, ShiftType> offlineMap = {};
          decoded.forEach((key, value) {
            final date = DateTime.parse(key);
            offlineMap[DateTime(date.year, date.month, date.day)] = _parseShiftType(value.toString());
          });
          return offlineMap;
        } catch (_) {}
      }
      throw ApiException.fromDioException(e);
    }
  }

  ShiftType _parseShiftType(String typeStr) {
    final lower = typeStr.toLowerCase();
    if (lower.contains('long') || lower.contains('day') || lower.contains('صباحي')) {
      return ShiftType.long;
    } else if (lower.contains('night') || lower.contains('سهر') || lower.contains('ليلي')) {
      return ShiftType.night;
    }
    return ShiftType.off;
  }
}
