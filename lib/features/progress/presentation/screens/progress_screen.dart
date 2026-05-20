import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smoke_smarter_app/features/daily_log/data/daily_log.dart';
import 'package:smoke_smarter_app/features/daily_log/providers/log_providers.dart';
import 'package:smoke_smarter_app/features/user_profile/providers/user_profile_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final profile = ref.watch(userProfileProvider).valueOrNull;
    final weeklyAsync = ref.watch(weeklyLogsProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    final daysSinceStart = profile?.quitStartDate != null
        ? DateTime.now().difference(profile!.quitStartDate!).inDays + 1
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Weekly overview
          Text(
            'This week',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          weeklyAsync.when(
            loading: () => const Card(
              child: SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, __) => const Card(
              child: SizedBox(
                height: 160,
                child: Center(child: Text('Could not load chart')),
              ),
            ),
            data: (logs) => _WeeklyChart(
              logs: logs,
              goal: profile?.cigarettesPerDay ?? 10,
              colorScheme: colorScheme,
              theme: theme,
            ),
          ),
          const SizedBox(height: 24),

          // Summary row
          if (statsAsync.valueOrNull != null) ...[
            _SummaryRow(
              stats: statsAsync.value!,
              daysSinceStart: daysSinceStart,
              colorScheme: colorScheme,
              theme: theme,
            ),
            const SizedBox(height: 24),
          ],

          // Milestones
          Text(
            'Milestones',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ..._buildMilestones(daysSinceStart).map(
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

  List<_Milestone> _buildMilestones(int daysSinceStart) => [
        _Milestone(
            label: '1 day on your journey',
            emoji: '🌅',
            achieved: daysSinceStart >= 1),
        _Milestone(
            label: '3 days on your journey',
            emoji: '💪',
            achieved: daysSinceStart >= 3),
        _Milestone(
            label: '1 week on your journey',
            emoji: '🔥',
            achieved: daysSinceStart >= 7),
        _Milestone(
            label: '2 weeks on your journey',
            emoji: '🏆',
            achieved: daysSinceStart >= 14),
        _Milestone(
            label: '1 month on your journey',
            emoji: '🎉',
            achieved: daysSinceStart >= 30),
        _Milestone(
            label: '3 months on your journey',
            emoji: '🌟',
            achieved: daysSinceStart >= 90),
        _Milestone(
            label: '6 months on your journey',
            emoji: '🥇',
            achieved: daysSinceStart >= 180),
        _Milestone(
            label: '1 year smoke-free',
            emoji: '👑',
            achieved: daysSinceStart >= 365),
      ];
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.stats,
    required this.daysSinceStart,
    required this.colorScheme,
    required this.theme,
  });

  final DashboardStats stats;
  final int daysSinceStart;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Days active',
            value: '$daysSinceStart',
            icon: Icons.calendar_today_outlined,
            colorScheme: colorScheme,
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Best streak',
            value: '${stats.streak}d',
            icon: Icons.local_fire_department_outlined,
            colorScheme: colorScheme,
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Saved',
            value: '\$${stats.moneySaved.toStringAsFixed(0)}',
            icon: Icons.savings_outlined,
            colorScheme: colorScheme,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.colorScheme,
    required this.theme,
  });

  final String label;
  final String value;
  final IconData icon;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Milestone {
  const _Milestone(
      {required this.label, required this.emoji, required this.achieved});

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
  const _WeeklyChart({
    required this.logs,
    required this.goal,
    required this.colorScheme,
    required this.theme,
  });

  final List<DailyLog> logs;
  final int goal;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Build a map of dateKey → count for quick lookup
    final logMap = {for (final l in logs) l.dateKey: l.count};

    final today = DateTime.now();
    // Build last 7 days (oldest → newest)
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxBar = (goal * 1.5).ceil().clamp(1, 999);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cigarettes per day',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Goal: $goal',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(days.length, (i) {
                  final day = days[i];
                  final key =
                      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                  final count = logMap[key] ?? 0;
                  final isToday = i == 6;
                  final overGoal = count > goal;
                  final ratio = (count / maxBar).clamp(0.0, 1.0);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (count > 0)
                            Text(
                              '$count',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: overGoal
                                    ? colorScheme.error
                                    : colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration:
                                    Duration(milliseconds: 400 + i * 60),
                                curve: Curves.easeOut,
                                width: double.infinity,
                                height: ratio * 100 + (count > 0 ? 4 : 0),
                                decoration: BoxDecoration(
                                  color: overGoal
                                      ? colorScheme.errorContainer
                                      : isToday
                                          ? colorScheme.primary
                                          : colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dayLabels[day.weekday - 1],
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
            // Goal line indicator
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.primary.withAlpha(80),
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'daily goal',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary.withAlpha(150),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

