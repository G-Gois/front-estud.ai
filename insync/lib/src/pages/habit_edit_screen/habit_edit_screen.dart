import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insync/src/backend/api_requests/models/api_habit_model.dart';
import 'package:insync/src/pages/habit_edit_screen/habit_edit_screen_controller.dart';

class HabitEditScreen extends ConsumerStatefulWidget {
  final ApiHabitModel habit;

  const HabitEditScreen({
    super.key,
    required this.habit,
  });

  @override
  ConsumerState<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends ConsumerState<HabitEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  HabitEditScreenController get controller => ref.watch(habitEditScreenControllerProvider(context));

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.name);
    _descriptionController = TextEditingController(text: widget.habit.description ?? '');

    // Initialize controller with habit data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeWithHabit(widget.habit);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color _getSelectedColor() {
    try {
      return Color(int.parse(controller.selectedColor.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _getSelectedColor();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Edit Habit'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Habit'),
                  content: const Text('Are you sure you want to delete this habit? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                controller.deleteHabit(widget.habit.id);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: accentColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _nameController.text.isEmpty ? 'Habit name' : _nameController.text,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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
                    prefixIcon: Icon(Icons.edit_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter habit name';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe your habit...',
                    prefixIcon: Icon(Icons.description_rounded),
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
                  child: OutlinedButton(
                    onPressed: !controller.isLoading
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              controller.updateHabit(
                                habitId: widget.habit.id,
                                name: _nameController.text,
                                active: !widget.habit.active,
                                description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                              );
                            }
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: accentColor,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        if (controller.isLoading) {
                          return const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          );
                        }

                        return Text(
                          widget.habit.active ? 'Deactivate Habit' : 'Activate Habit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: !controller.isLoading
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              controller.updateHabit(
                                active: widget.habit.active,
                                habitId: widget.habit.id,
                                name: _nameController.text,
                                description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        if (controller.isLoading) {
                          return const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          );
                        }

                        return const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      },
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
        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
      ),
    );
  }
}
