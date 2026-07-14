import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/local_storage.dart';

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return LedgerRepository(dio);
});

class LedgerRepository {
  final Dio _dio;

  LedgerRepository(this._dio);

  /// Fetch financial ledger entries (IOU debits and claims in EGP ج.م)
  Future<List<Map<String, dynamic>>> getLedgerEntries() async {
    const cacheKey = 'ledger_entries_cache';
    final box = HiveCacheService.getLedgerBox();

    try {
      final response = await _dio.get(ApiConstants.ledger);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> rawList = response.data is List ? response.data : (response.data['items'] ?? []);
        final entries = rawList.map((e) => Map<String, dynamic>.from(e)).toList();

        await box.put(cacheKey, jsonEncode(entries));
        return entries;
      }
      return [];
    } on DioException catch (e) {
      if (box.containsKey(cacheKey)) {
        try {
          final String cachedJson = box.get(cacheKey);
          final List<dynamic> decoded = jsonDecode(cachedJson);
          return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        } catch (_) {}
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// Settle debt transaction (Only creditor can settle successfully per backend 403 enforcement)
  Future<bool> settleDebtEntry(int ledgerId) async {
    try {
      final response = await _dio.patch(ApiConstants.settleDebt(ledgerId));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
