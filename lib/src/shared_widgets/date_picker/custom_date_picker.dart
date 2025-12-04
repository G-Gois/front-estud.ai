import 'package:estud_ai/src/core/constants/app_colors.dart';
import 'package:estud_ai/src/core/constants/app_spacing.dart';
import 'package:estud_ai/src/core/extensions/build_context_extension.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();

  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomDatePicker(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;
  int _step = 1; // 1: year, 2: month, 3: day
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Sempre começa no step 1 (ano), mas pré-seleciona os valores se houver initialDate
    if (widget.initialDate != null) {
      _selectedYear = widget.initialDate!.year;
      _selectedMonth = widget.initialDate!.month;
      _selectedDay = widget.initialDate!.day;

      // Scroll para o ano pré-selecionado após o build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && _selectedYear != null) {
          final index = _years.indexOf(_selectedYear!);
          if (index != -1) {
            _scrollController.animateTo(
              index * 56.0, // altura aproximada de cada item
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<int> get _years {
    return List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (index) => widget.lastDate.year - index,
    );
  }

  List<int> get _months => List.generate(12, (index) => index + 1);

  List<int> get _days {
    if (_selectedYear == null || _selectedMonth == null) return [];
    final daysInMonth = DateTime(_selectedYear!, _selectedMonth! + 1, 0).day;
    return List.generate(daysInMonth, (index) => index + 1);
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }

  void _selectYear(int year) {
    setState(() {
      _selectedYear = year;
      _step = 2;
    });
  }

  void _selectMonth(int month) {
    setState(() {
      _selectedMonth = month;
      _step = 3;
    });
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDay = day;
    });
    // Fecha o modal e retorna a data selecionada
    Navigator.pop(context, DateTime(_selectedYear!, _selectedMonth!, day));
  }

  void _goBack() {
    setState(() {
      if (_step > 1) _step--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderSoft,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                if (_step > 1)
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft),
                    onPressed: _goBack,
                    color: AppColors.textMain,
                  ),
                Expanded(
                  child: Text(
                    _step == 1
                        ? 'Selecione o ano'
                        : _step == 2
                            ? 'Selecione o mês'
                            : 'Selecione o dia',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: _step == 1 ? TextAlign.center : TextAlign.left,
                  ),
                ),
                if (_step == 1)
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),

          // Selected date display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.backgroundSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 16,
                  color: _selectedYear != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedYear == null
                      ? 'Nenhuma data selecionada'
                      : _selectedDay != null
                          ? '$_selectedDay/${_selectedMonth!.toString().padLeft(2, '0')}/$_selectedYear'
                          : _selectedMonth != null
                              ? '${_getMonthName(_selectedMonth!)} $_selectedYear'
                              : '$_selectedYear',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: _selectedYear != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: _selectedYear != null
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Content
          Expanded(
            child: _step == 1
                ? _buildYearSelector()
                : _step == 2
                    ? _buildMonthSelector()
                    : _buildDaySelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: _years.length,
      itemBuilder: (context, index) {
        final year = _years[index];
        final isSelected = year == _selectedYear;

        return GestureDetector(
          onTap: () => _selectYear(year),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.backgroundSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              year.toString(),
              style: context.textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.white : AppColors.textMain,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthSelector() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 2,
      ),
      itemCount: _months.length,
      itemBuilder: (context, index) {
        final month = _months[index];
        final isSelected = month == _selectedMonth;

        return GestureDetector(
          onTap: () => _selectMonth(month),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.backgroundSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _getMonthName(month),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : AppColors.textMain,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDaySelector() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
        childAspectRatio: 1,
      ),
      itemCount: _days.length,
      itemBuilder: (context, index) {
        final day = _days[index];
        final isSelected = day == _selectedDay;

        return GestureDetector(
          onTap: () => _selectDay(day),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.backgroundSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : AppColors.textMain,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
