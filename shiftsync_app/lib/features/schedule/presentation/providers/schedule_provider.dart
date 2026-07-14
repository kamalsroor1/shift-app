import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/shift_badge.dart';
import '../../domain/repositories/schedule_repository.dart';

final scheduleNotifierProvider = AsyncNotifierProvider<ScheduleNotifier, Map<DateTime, ShiftType>>(ScheduleNotifier.new);

class ScheduleNotifier extends AsyncNotifier<Map<DateTime, ShiftType>> {
  @override
  Future<Map<DateTime, ShiftType>> build() async {
    final now = DateTime.now();
    return await _fetchMonth(now.year, now.month);
  }

  Future<Map<DateTime, ShiftType>> _fetchMonth(int year, int month) async {
    try {
      final repository = ref.read(scheduleRepositoryProvider);
      return await repository.getMonthlySchedule(year, month);
    } catch (_) {
      // Return empty map on failure so UI fallback shifts can render smoothly
      return {};
    }
  }

  Future<void> fetchCurrentMonth() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final now = DateTime.now();
      return await _fetchMonth(now.year, now.month);
    });
  }

  Future<void> fetchMonth(int year, int month) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _fetchMonth(year, month));
  }

  Future<void> updateShift(DateTime date, ShiftType newShift) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final currentMap = state.value != null ? Map<DateTime, ShiftType>.from(state.value!) : <DateTime, ShiftType>{};
    currentMap[normalized] = newShift;
    state = AsyncValue.data(currentMap);
  }
}
