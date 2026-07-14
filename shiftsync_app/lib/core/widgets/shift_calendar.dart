import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_tokens.dart';
import 'shift_badge.dart';

/// ShiftCalendar — Interactive bilingual/Arabic-First calendar widget allowing nurses
/// to navigate month-by-month or toggle between weekly and monthly views, displaying shift dots.
class ShiftCalendar extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final Map<DateTime, ShiftType> shifts;

  const ShiftCalendar({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.shifts,
  });

  @override
  State<ShiftCalendar> createState() => _ShiftCalendarState();
}

class _ShiftCalendarState extends State<ShiftCalendar> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.week; // default compact weekly, toggles to month
    _focusedDay = widget.selectedDay;
  }

  // Helper to normalize dates for shift lookup
  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.cardShadow,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Header with format toggle button (أسبوع / شهر كامل)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    DateFormat('MMMM yyyy', 'ar').format(_focusedDay),
                    style: AppTextStyles.headingMd,
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _calendarFormat = _calendarFormat == CalendarFormat.week
                        ? CalendarFormat.month
                        : CalendarFormat.week;
                  });
                },
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _calendarFormat == CalendarFormat.week ? Icons.unfold_more_rounded : Icons.unfold_less_rounded,
                        size: 16,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _calendarFormat == CalendarFormat.week ? 'عرض الشهر الكامل' : 'عرض أسبوعي',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // TableCalendar implementation with sleek Arabic tokens
          TableCalendar(
            locale: 'ar',
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(widget.selectedDay, selectedDay)) {
                widget.onDaySelected(selectedDay, focusedDay);
                setState(() {
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            headerVisible: false, // We built our own custom header above!
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
              weekendStyle: AppTextStyles.caption.copyWith(color: AppColors.debtRed, fontWeight: FontWeight.w700),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: AppTextStyles.bodyMd,
              weekendTextStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.debtRed),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              todayTextStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w700),
              selectedTextStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.surface, fontWeight: FontWeight.w700),
            ),
            eventLoader: (day) {
              final norm = _normalizeDate(day);
              final shift = widget.shifts[norm];
              return shift != null ? [shift] : [];
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                final shift = events.first as ShiftType;
                Color dotColor;
                switch (shift) {
                  case ShiftType.long:
                    dotColor = AppColors.shiftLong;
                    break;
                  case ShiftType.night:
                    dotColor = AppColors.shiftNight;
                    break;
                  case ShiftType.off:
                    dotColor = AppColors.shiftOff;
                    break;
                }
                return Positioned(
                  bottom: 4,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
