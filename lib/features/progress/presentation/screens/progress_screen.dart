import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Weekly overview
          Text(
            'This week',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _WeeklyChart(colorScheme: colorScheme, theme: theme),
          const SizedBox(height: 24),

          // Milestones
          Text(
            'Milestones',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ..._milestones.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MilestoneTile(
                milestone: m,
                colorScheme: colorScheme,
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _milestones = [
  _Milestone(label: '1 hour smoke-free', emoji: '⏱️', achieved: true),
  _Milestone(label: '1 day smoke-free', emoji: '🌅', achieved: true),
  _Milestone(label: '3 days smoke-free', emoji: '💪', achieved: true),
  _Milestone(label: '1 week smoke-free', emoji: '🔥', achieved: true),
  _Milestone(label: '2 weeks smoke-free', emoji: '🏆', achieved: false),
  _Milestone(label: '1 month smoke-free', emoji: '🎉', achieved: false),
  _Milestone(label: '3 months smoke-free', emoji: '🌟', achieved: false),
];

class _Milestone {
  const _Milestone({
    required this.label,
    required this.emoji,
    required this.achieved,
  });

  final String label;
  final String emoji;
  final bool achieved;
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.milestone,
    required this.colorScheme,
    required this.theme,
  });

  final _Milestone milestone;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: milestone.achieved
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: Text(
          milestone.emoji,
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(
          milestone.label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: milestone.achieved
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          milestone.achieved
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: milestone.achieved
              ? colorScheme.primary
              : colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.colorScheme, required this.theme});

  final ColorScheme colorScheme;
  final ThemeData theme;

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _counts = [5, 4, 3, 2, 3, 1, 0];
  static const _maxGoal = 5;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cigarettes per day',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_days.length, (i) {
                  final ratio = _counts[i] / _maxGoal;
                  final isToday = i == 6;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 400 + i * 60),
                                curve: Curves.easeOut,
                                width: double.infinity,
                                height: ratio * 90 + 4,
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? colorScheme.primary
                                      : colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _days[i],
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isToday
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
