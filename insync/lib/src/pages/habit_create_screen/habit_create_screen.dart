import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insync/src/pages/habit_create_screen/habit_create_screen_controller.dart';

class HabitCreateScreen extends ConsumerStatefulWidget {
  const HabitCreateScreen({super.key});

  @override
  ConsumerState<HabitCreateScreen> createState() => _HabitCreateScreenState();
}

class _HabitCreateScreenState extends ConsumerState<HabitCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  HabitCreateScreenController get controller =>
      ref.watch(habitCreateScreenControllerProvider(context));

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Habit Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'Habit name',
                    hintText: 'e.g. Drink water',
                    prefixIcon: Icon(Icons.edit),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter habit name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe your habit...',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Frequency',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildFrequencyChip('daily', 'Daily', colorScheme),
                    _buildFrequencyChip('weekly', 'Weekly', colorScheme),
                  ],
                ),
                if (controller.selectedFrequency == 'weekly') ...[
                  const SizedBox(height: 24),
                  Text(
                    'Days of Week',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildDayChip(1, 'Mon', colorScheme),
                      _buildDayChip(2, 'Tue', colorScheme),
                      _buildDayChip(3, 'Wed', colorScheme),
                      _buildDayChip(4, 'Thu', colorScheme),
                      _buildDayChip(5, 'Fri', colorScheme),
                      _buildDayChip(6, 'Sat', colorScheme),
                      _buildDayChip(7, 'Sun', colorScheme),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  'Color',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildColorChip('#A8DADC', colorScheme), // Pastel Blue
                    _buildColorChip('#F1FAEE', colorScheme), // Cream White
                    _buildColorChip('#E76F51', colorScheme), // Terracotta
                    _buildColorChip('#F4A261', colorScheme), // Sandy Orange
                    _buildColorChip('#E9C46A', colorScheme), // Soft Yellow
                    _buildColorChip('#2A9D8F', colorScheme), // Teal
                    _buildColorChip('#264653', colorScheme), // Dark Blue
                    _buildColorChip('#DDA15E', colorScheme), // Tan
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              controller.createHabit(
                                name: _nameController.text,
                                description: _descriptionController.text.isEmpty
                                    ? null
                                    : _descriptionController.text,
                              );
                            }
                          },
                    child: controller.isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Text(
                            'Create Habit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyChip(String value, String label, ColorScheme colorScheme) {
    final isSelected = controller.selectedFrequency == value;
    final textColor = colorScheme.primary.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.setFrequency(value),
      selectedColor: colorScheme.primary,
      showCheckmark: true,
      checkmarkColor: textColor,
      labelStyle: TextStyle(
        color: isSelected ? textColor : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildDayChip(int day, String label, ColorScheme colorScheme) {
    final isSelected = controller.selectedDaysOfWeek.contains(day);
    final checkColor = colorScheme.primary.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final textColor = colorScheme.primary.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.toggleDayOfWeek(day),
      selectedColor: colorScheme.primary,
      checkmarkColor: checkColor,
      labelStyle: TextStyle(
        color: isSelected ? textColor : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildColorChip(String color, ColorScheme colorScheme) {
    final isSelected = controller.selectedColor == color;
    final chipColor = Color(int.parse(color.replaceFirst('#', '0xff')));

    // Calculates icon color based on background color luminosity
    final iconColor = chipColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: () => controller.setColor(color),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: chipColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? colorScheme.onSurface : Colors.transparent,
            width: 3,
          ),
        ),
        child: isSelected
            ? Icon(Icons.check, color: iconColor, size: 24)
            : null,
      ),
    );
  }
}
