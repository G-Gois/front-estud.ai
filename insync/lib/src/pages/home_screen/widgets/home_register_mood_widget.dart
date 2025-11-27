import 'package:flutter/material.dart';
import 'package:insync/src/core/exntesions/build_context_extension.dart';

class HomeRegisterMoodWidget extends StatelessWidget {
  const HomeRegisterMoodWidget({
    super.key,
    required this.date,
    this.selectedMood,
    required this.onMoodSelected,
  });

  final DateTime date;
  final int? selectedMood;

  final void Function(int moodIndex) onMoodSelected;

  String getFormattedTitle() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    final difference = selectedDay.difference(today).inDays;

    if (difference == 0) return 'How is your mood today?';
    if (difference == -1) return 'How was your mood yesterday?';
    if (difference == -2) return 'How was your mood 2 days ago?';

    return 'How was your mood on ${selectedDay.day}/${selectedDay.month}?';
  }

  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
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
                Icons.mood,
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
                      isToday ? 'Select how you feel' : 'Select how you felt',
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
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final isSelected = selectedMood == index;
                return GestureDetector(
                  onTap: selectedMood != null ? null : () => onMoodSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 50 : 44,
                    height: isSelected ? 50 : 44,
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
                      child: Icon(
                        _getMoodIcon(index),
                        size: isSelected ? 28 : 24,
                        color: isSelected ? colorScheme.onPrimary : colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  IconData _getMoodIcon(int index) {
    switch (index) {
      case 0:
        return Icons.sentiment_very_dissatisfied_outlined; // Muito triste
      case 1:
        return Icons.sentiment_dissatisfied_outlined; // Triste
      case 2:
        return Icons.sentiment_neutral_outlined; // Neutro
      case 3:
        return Icons.sentiment_satisfied_outlined; // Feliz
      case 4:
        return Icons.sentiment_very_satisfied_outlined; // Muito feliz
      default:
        return Icons.sentiment_neutral_outlined;
    }
  }
}
