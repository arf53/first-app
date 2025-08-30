import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: habit.isCompleted
            ? Border.all(color: Colors.green, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(theme, colorScheme),
            const SizedBox(height: 16),
            _buildProgressBar(colorScheme),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: habit.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              habit.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    habit.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (habit.isCompleted) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ],
                ],
              ),
              Row(
                children: [
                  Text(
                    habit.progressText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '🔥 ${habit.streakDays} gün',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    return LinearProgressIndicator(
      value: habit.progress.clamp(0.0, 1.0),
      backgroundColor: colorScheme.outline.withOpacity(0.2),
      valueColor: AlwaysStoppedAnimation<Color>(habit.color),
      minHeight: 8,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.remove,
          onPressed: onDecrement,
          color: Colors.red,
          enabled: habit.currentCount > 0,
        ),
        _buildActionButton(
          icon: Icons.refresh,
          onPressed: onReset,
          color: Colors.orange,
        ),
        _buildActionButton(
          icon: Icons.add,
          onPressed: onIncrement,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool enabled = true,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        foregroundColor: enabled ? color : Colors.grey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
      ),
      child: Icon(icon),
    );
  }
}