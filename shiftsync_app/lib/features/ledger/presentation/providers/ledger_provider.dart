import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/ledger_repository.dart';

final ledgerNotifierProvider = AsyncNotifierProvider<LedgerNotifier, List<Map<String, dynamic>>>(LedgerNotifier.new);

class LedgerNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return await _fetchEntries();
  }

  Future<List<Map<String, dynamic>>> _fetchEntries() async {
    try {
      final repository = ref.read(ledgerRepositoryProvider);
      return await repository.getLedgerEntries();
    } catch (_) {
      return [];
    }
  }

  Future<void> fetchEntries() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _fetchEntries());
  }

  Future<bool> settleEntry(int ledgerId) async {
    try {
      final repository = ref.read(ledgerRepositoryProvider);
      final success = await repository.settleDebtEntry(ledgerId);
      if (success) {
        await fetchEntries();
      }
      return success;
    } catch (e) {
      rethrow;
    }
  }
}
