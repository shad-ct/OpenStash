import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../repositories/streak_repository.dart';
import '../theme/tokens.dart';

class StreakCalendarBottomSheet extends StatefulWidget {
  const StreakCalendarBottomSheet({super.key});

  @override
  State<StreakCalendarBottomSheet> createState() => _StreakCalendarBottomSheetState();
}

class _StreakCalendarBottomSheetState extends State<StreakCalendarBottomSheet> {
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _completedDates = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dates = await streakRepository.getCompletedDates();
    if (mounted) {
      setState(() {
        _completedDates = dates.toSet();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(AppTokens.p24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTokens.p24),
          Text(
            'Your Reading Streak',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: AppTokens.p16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _buildCalendarCell(day, isToday: isSameDay(day, DateTime.now()));
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildCalendarCell(day, isToday: true);
                },
              ),
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          const SizedBox(height: AppTokens.p16),
        ],
      ),
    );
  }

  Widget _buildCalendarCell(DateTime day, {bool isToday = false}) {
    final isCompleted = _completedDates.any((d) => isSameDay(d, day));
    
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday ? Theme.of(context).dividerColor.withOpacity(0.2) : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.local_fire_department, color: Colors.red, size: 24)
            : Text(
                '${day.day}',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
      ),
    );
  }
}
