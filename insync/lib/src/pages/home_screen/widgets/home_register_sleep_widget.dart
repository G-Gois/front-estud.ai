import 'package:flutter/material.dart';
import 'package:insync/src/core/exntesions/build_context_extension.dart';

class HomeRegisterSleepWidget extends StatefulWidget {
  const HomeRegisterSleepWidget({
    super.key,
    required this.date,
    this.selectedHours,
    required this.onSleepHoursSelected,
  });

  final DateTime date;
  final int? selectedHours;
  final void Function(int hours) onSleepHoursSelected;

  @override
  State<HomeRegisterSleepWidget> createState() => _HomeRegisterSleepWidgetState();
}

class _HomeRegisterSleepWidgetState extends State<HomeRegisterSleepWidget> {
  late ScrollController _scrollController;
  final double itemWidth = 60.0;
  final int totalHours = 25; // 0 to 24

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(itemWidth * 10);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String getFormattedTitle() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(widget.date.year, widget.date.month, widget.date.day);
    final difference = selectedDay.difference(today).inDays;

    if (difference == 0) return 'How many hours did you sleep last night?';
    if (difference == -1) return 'How many hours did you sleep yesterday?';
    if (difference == -2) return 'How many hours did you sleep 2 days ago?';

    return 'How many hours did you sleep on ${selectedDay.day}/${selectedDay.month}?';
  }

  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(widget.date.year, widget.date.month, widget.date.day);
    return today == selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bedtime,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getFormattedTitle(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Tap to select hours (0-24)',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              SizedBox(
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              colorScheme.surface,
                              colorScheme.surface.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              colorScheme.surface,
                              colorScheme.surface.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: 1000,
                      itemBuilder: (context, index) {
                        final hour = index % totalHours;
                        final isSelected = widget.selectedHours == hour;

                        return GestureDetector(
                          onTap: widget.selectedHours != null ? null : () => widget.onSleepHoursSelected(hour),
                          child: Container(
                            width: itemWidth,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected ? colorScheme.primary : colorScheme.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? colorScheme.primary : colorScheme.primary.withValues(alpha: 0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$hour',
                                  style: TextStyle(
                                    fontSize: isSelected ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected ? colorScheme.onPrimary : colorScheme.primary.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
