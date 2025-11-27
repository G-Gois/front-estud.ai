import 'package:flutter/material.dart';

class CalendarRangePickerWidget extends StatefulWidget {
  final ColorScheme colorScheme;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final String pickerTitle;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Function(DateTime, DateTime) onDateSelected;

  const CalendarRangePickerWidget({
    super.key,
    required this.colorScheme,
    this.pickerTitle = 'Select Date',
    this.minDate,
    this.maxDate,
    required this.onDateSelected,
    required this.selectedStartDate,
    required this.selectedEndDate,
  });

  @override
  State<CalendarRangePickerWidget> createState() => _CalendarRangePickerWidgetState();
}

class _CalendarRangePickerWidgetState extends State<CalendarRangePickerWidget> {
  late DateTime _currentMonth;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isSelectingEndDate = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    if (widget.selectedEndDate != null) {
      _currentMonth = DateTime(widget.selectedEndDate!.year, widget.selectedEndDate!.month);
    } else if (widget.selectedStartDate != null) {
      _currentMonth = DateTime(widget.selectedStartDate!.year, widget.selectedStartDate!.month);
    } else {
      _currentMonth = DateTime(now.year, now.month);
    }

    _selectedStartDate = widget.selectedStartDate;
    _selectedEndDate = widget.selectedEndDate;

    if (_selectedStartDate != null && _selectedEndDate != null) {
      _isSelectingEndDate = false;
    } else if (_selectedStartDate != null) {
      _isSelectingEndDate = true;
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

    final firstWeekday = firstDay.weekday;
    final days = <DateTime?>[];
    for (int i = 1; i < firstWeekday; i++) {
      days.add(null);
    }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                if (_selectedStartDate != null || _selectedEndDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _getSubtitle(),
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
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

                  // Check if date is start or end of range
                  final isStartDate = _selectedStartDate != null &&
                      _selectedStartDate!.year == date.year &&
                      _selectedStartDate!.month == date.month &&
                      _selectedStartDate!.day == date.day;

                  final isEndDate = _selectedEndDate != null &&
                      _selectedEndDate!.year == date.year &&
                      _selectedEndDate!.month == date.month &&
                      _selectedEndDate!.day == date.day;

                  // Check if date is in range
                  final isInRange = _selectedStartDate != null &&
                      _selectedEndDate != null &&
                      date.isAfter(_selectedStartDate!) &&
                      date.isBefore(_selectedEndDate!);

                  final isDisabled = widget.minDate != null && date.isBefore(widget.minDate!) ||
                      widget.maxDate != null && date.isAfter(widget.maxDate!);

                  return GestureDetector(
                    onTap: isDisabled
                        ? null
                        : () {
                            _handleDateSelection(date);
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: (isStartDate || isEndDate)
                            ? widget.colorScheme.primary
                            : isInRange
                                ? widget.colorScheme.primary.withValues(alpha: 0.3)
                                : isToday
                                    ? widget.colorScheme.primary.withValues(alpha: 0.15)
                                    : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday && !(isStartDate || isEndDate || isInRange)
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
                            fontWeight: isToday || isStartDate || isEndDate ? FontWeight.bold : FontWeight.normal,
                            color: isDisabled
                                ? widget.colorScheme.onSurface.withValues(alpha: 0.3)
                                : (isStartDate || isEndDate)
                                    ? widget.colorScheme.onPrimary
                                    : isInRange
                                        ? widget.colorScheme.primary
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

  void _handleDateSelection(DateTime selectedDate) {
    setState(() {
      if (_selectedStartDate == null || (!_isSelectingEndDate && _selectedStartDate != null)) {
        // Select start date (or restart selection)
        _selectedStartDate = selectedDate;
        _selectedEndDate = null;
        _isSelectingEndDate = true;
      } else if (_isSelectingEndDate) {
        // Select end date
        if (selectedDate.isAtSameMomentAs(_selectedStartDate!)) {
          // Same date selected, treat as single day range
          _selectedEndDate = selectedDate;
          _isSelectingEndDate = false;

          // Call the callback with both dates
          widget.onDateSelected(_selectedStartDate!, _selectedEndDate!);
          Navigator.pop(context);
        } else if (selectedDate.isBefore(_selectedStartDate!)) {
          // If selected date is before start date, make it the new start date
          _selectedStartDate = selectedDate;
          _selectedEndDate = null;
          _isSelectingEndDate = true;
        } else {
          // Valid end date selection
          _selectedEndDate = selectedDate;
          _isSelectingEndDate = false;

          // Call the callback with both dates
          widget.onDateSelected(_selectedStartDate!, _selectedEndDate!);
          Navigator.pop(context);
        }
      }
    });
  }

  String _getSubtitle() {
    if (_selectedStartDate == null) {
      return 'Select the start date';
    } else if (_selectedStartDate != null && _selectedEndDate != null) {
      return 'Range selected: from ${_formatDate(_selectedStartDate!)} to ${_formatDate(_selectedEndDate!)}';
    }
    return 'Select the end date';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
