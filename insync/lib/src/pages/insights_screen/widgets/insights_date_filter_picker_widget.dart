import 'package:flutter/material.dart';

enum DateFilterOption { sevenDays, lastMonth, personalized }

class InsightsDateFilterPickerWidget extends StatefulWidget {
  const InsightsDateFilterPickerWidget({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.colorScheme,
  });

  final Function(DateFilterOption option) onOptionSelected;
  final DateFilterOption selectedOption;
  final ColorScheme colorScheme;

  @override
  State<InsightsDateFilterPickerWidget> createState() => _InsightsDateFilterPickerWidgetState();
}

class _InsightsDateFilterPickerWidgetState extends State<InsightsDateFilterPickerWidget> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: widget.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: [
          Expanded(child: _buildButton(DateFilterOption.sevenDays, 'Last 7 days')),
          Expanded(child: _buildButton(DateFilterOption.lastMonth, 'Last month')),
          Expanded(child: _buildButton(DateFilterOption.personalized, 'Personalized')),
        ],
      ),
    );
  }

  Widget _buildButton(DateFilterOption option, String text) {
    final bool isActive = widget.selectedOption == option;

    return GestureDetector(
      onTap: () {
        widget.onOptionSelected(option);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? widget.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: widget.colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? widget.colorScheme.onPrimary : widget.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
