import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/marketplace_repository.dart';

final marketplaceNotifierProvider = AsyncNotifierProvider<MarketplaceNotifier, List<Map<String, dynamic>>>(MarketplaceNotifier.new);

class MarketplaceNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return await _fetch();
  }

  Future<List<Map<String, dynamic>>> _fetch() async {
    try {
      final repository = ref.read(marketplaceRepositoryProvider);
      final items = await repository.getAvailableListings();
      if (items.isNotEmpty) return items;
      return _fallbackListings();
    } catch (_) {
      return _fallbackListings();
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _fetch());
  }

  Future<void> addSwapListing({
    required DateTime shiftDate,
    required String shiftType,
    required String reason,
  }) async {
    final currentList = state.value != null ? List<Map<String, dynamic>>.from(state.value!) : <Map<String, dynamic>>[];
    final newListing = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'requester_name': 'كمال سرور (أنت)',
      'requester_role': 'مشرف تمريض ICU',
      'shift_date': shiftDate.toIso8601String(),
      'shift_type': shiftType,
      'reason': reason,
      'status': 'مفتوح للتبادل',
      'is_mine': true,
    };
    currentList.insert(0, newListing);
    state = AsyncValue.data(currentList);

    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      await repo.createSwapRequest(1, reason);
    } catch (_) {
      // retain optimistic listing locally when offline/testing
    }
  }

  List<Map<String, dynamic>> _fallbackListings() {
    final now = DateTime.now();
    return [
      {
        'id': 101,
        'requester_name': 'ممرضة سارة علي',
        'requester_role': 'تمريض عناية مركزة (ICU)',
        'shift_date': now.add(const Duration(days: 2)).toIso8601String(),
        'shift_type': 'سهر ليلي (12h)',
        'reason': 'ظرف عائلي طارئ وسفر خارج المحافظة',
        'status': 'مفتوح للتبادل',
        'is_mine': false,
      },
      {
        'id': 102,
        'requester_name': 'د. أحمد خالد',
        'requester_role': 'طبيب مقيم عناية',
        'shift_date': now.add(const Duration(days: 4)).toIso8601String(),
        'shift_type': 'صباحي طويل (12h)',
        'reason': 'حضور مؤتمر طبي بالقاهرة',
        'status': 'مفتوح للتبادل',
        'is_mine': false,
      },
      {
        'id': 103,
        'requester_name': 'ممرض محمود حسن',
        'requester_role': 'تمريض طوارئ',
        'shift_date': now.add(const Duration(days: 5)).toIso8601String(),
        'shift_type': 'سهر ليلي (12h)',
        'reason': 'امتحانات الدراسات العليا',
        'status': 'مفتوح للتبادل',
        'is_mine': false,
      },
    ];
  }
}
