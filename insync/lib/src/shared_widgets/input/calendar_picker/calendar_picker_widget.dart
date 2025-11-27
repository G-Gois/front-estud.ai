import 'package:flutter/material.dart';

class CalendarPickerWidget extends StatefulWidget {
  final ColorScheme colorScheme;
  final DateTime? selectedDate;
  final String pickerTitle;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Function(DateTime) onDateSelected;

  const CalendarPickerWidget({
    super.key,
    required this.colorScheme,
    this.pickerTitle = 'Select Date',
    required this.selectedDate,
    this.minDate,
    this.maxDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarPickerWidget> createState() => _CalendarPickerWidgetState();
}

class _CalendarPickerWidgetState extends State<CalendarPickerWidget> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (widget.selectedDate != null) {
      _currentMonth = DateTime(widget.selectedDate!.year, widget.selectedDate!.month);
    } else {
      _currentMonth = DateTime(now.year, now.month);
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  bool _canGoPrevious() {
    if (widget.minDate == null) return true;

    final previousMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    return previousMonth.isAfter(widget.minDate!) ||
        previousMonth.year == widget.minDate?.year && previousMonth.month == widget.minDate?.month;
  }

  bool _canGoNext() {
    if (widget.maxDate == null) return true;
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    return nextMonth.isBefore(widget.maxDate!) ||
        nextMonth.year == widget.maxDate!.year && nextMonth.month <= widget.maxDate!.month;
  }

  List<DateTime?> _getDaysInMonth() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    // Get weekday of first day (1 = Monday, 7 = Sunday)
    final firstWeekday = firstDay.weekday;

    // Add empty cells for days before month starts
    final days = <DateTime?>[];
    for (int i = 1; i < firstWeekday; i++) {
      days.add(null);
    }

    // Add all days of month
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);

      final isAllowedMin = widget.minDate == null || !date.isBefore(widget.minDate!);
      final isAllowedMax = widget.maxDate == null || !date.isAfter(widget.maxDate!);
      final isBeforeMinDate = widget.minDate != null && date.isBefore(widget.minDate!);

      if (isAllowedMin && isAllowedMax) {
        days.add(date);
      } else if (isBeforeMinDate) {
        days.add(null);
      } else {
        days.add(date);
      }
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.pickerTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: widget.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: widget.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _canGoPrevious() ? _previousMonth : null,
                  icon: Icon(
                    Icons.chevron_left,
                    color: _canGoPrevious()
                        ? widget.colorScheme.primary
                        : widget.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
                Text(
                  '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: widget.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: _canGoNext() ? _nextMonth : null,
                  icon: Icon(
                    Icons.chevron_right,
                    color:
                        _canGoNext() ? widget.colorScheme.primary : widget.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),

          // Weekday headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map(
                    (day) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Calendar grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _getDaysInMonth().length,
                itemBuilder: (context, index) {
                  final date = _getDaysInMonth()[index];

                  if (date == null) {
                    return const SizedBox.shrink();
                  }

                  final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
                  final isSelected = widget.selectedDate != null
                      ? widget.selectedDate!.year == date.year &&
                          widget.selectedDate!.month == date.month &&
                          widget.selectedDate!.day == date.day
                      : isToday;

                  final isDisabled = widget.minDate != null && date.isBefore(widget.minDate!) ||
                      widget.maxDate != null && date.isAfter(widget.maxDate!);

                  return GestureDetector(
                    onTap: isDisabled
                        ? null
                        : () {
                            widget.onDateSelected(date);
                            Navigator.pop(context);
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.colorScheme.primary
                            : isToday
                                ? widget.colorScheme.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday && !isSelected
                            ? Border.all(
                                color: widget.colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isDisabled
                                ? widget.colorScheme.onSurface.withValues(alpha: 0.3)
                                : isSelected
                                    ? widget.colorScheme.onPrimary
                                    : isToday
                                        ? widget.colorScheme.primary
                                        : widget.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
