import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smoke_smarter_app/features/auth/providers/auth_providers.dart';
import 'package:smoke_smarter_app/features/daily_log/providers/log_providers.dart';
import 'package:smoke_smarter_app/features/user_profile/providers/user_profile_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final profile = ref.watch(userProfileProvider).valueOrNull;
    final todayLog = ref.watch(todayLogProvider).valueOrNull;
    final statsAsync = ref.watch(dashboardStatsProvider);

    final goal = profile?.cigarettesPerDay ?? 10;
    final todayCount = todayLog?.count ?? 0;
    final stats = statsAsync.valueOrNull;

    // Greeting by time of day
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      appBar: AppBar(
        title: Text('$greeting 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Streak card
          _StreakCard(
            streak: stats?.streak ?? 0,
            isLoading: statsAsync.isLoading,
            colorScheme: colorScheme,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.attach_money_rounded,
                  label: 'Money saved',
                  value: stats == null
                      ? '--'
                      : '\$${stats.moneySaved.toStringAsFixed(2)}',
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.favorite_rounded,
                  label: 'Health score',
                  value: stats == null ? '--' : '${stats.healthScore}%',
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Today's log
          Text(
            "Today's log",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _TodayLogCard(
            count: todayCount,
            goal: goal,
            colorScheme: colorScheme,
            theme: theme,
            onLog: () => _logCigarette(context, ref, goal),
          ),
          const SizedBox(height: 16),

          // Quick tips
          Text(
            'Tips for today',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _TipCard(
            tip: _tipForDay(),
            colorScheme: colorScheme,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Future<void> _logCigarette(
      BuildContext context, WidgetRef ref, int goal) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    try {
      await ref.read(logRepositoryProvider).logCigarette(uid, goal: goal);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to log. Please try again.')),
        );
      }
    }
  }

  String _tipForDay() {
    const tips = [
      'When you feel a craving, try the 4-7-8 breathing technique — inhale for 4 seconds, hold for 7, exhale for 8.',
      'Drink a glass of water slowly when a craving hits. It helps the urge pass.',
      'Take a short walk. Physical activity, even 5 minutes, reduces cravings.',
      'Tell someone about your goal today — accountability boosts success rates.',
      'Cravings only last 3-5 minutes. Ride it out and you win.',
      'Replace the habit: chew gum, snack on carrots, or squeeze a stress ball.',
      'Remind yourself why you started — health, family, money, freedom.',
    ];
    return tips[DateTime.now().weekday % tips.length];
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.streak,
    required this.isLoading,
    required this.colorScheme,
    required this.theme,
  });

  final int streak;
  final bool isLoading;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final label = streak == 1 ? 'day' : 'days';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current streak',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary.withAlpha(200),
                  ),
                ),
                const SizedBox(height: 4),
                isLoading
                    ? SizedBox(
                        height: 28,
                        width: 120,
                        child: LinearProgressIndicator(
                          backgroundColor:
                              colorScheme.onPrimary.withAlpha(40),
                          color: colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : Text(
                        streak == 0
                            ? 'Start your streak today!'
                            : '$streak $label under goal',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                const SizedBox(height: 8),
                Text(
                  streak >= 7
                      ? 'Incredible! Keep it up!'
                      : streak >= 3
                          ? "You're building momentum!"
                          : "Every day counts. You've got this!",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withAlpha(40),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 28)),
                Text(
                  '$streak',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayLogCard extends StatelessWidget {
  const _TodayLogCard({
    required this.count,
    required this.goal,
    required this.colorScheme,
    required this.theme,
    required this.onLog,
  });

  final int count;
  final int goal;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (count / goal).clamp(0.0, 1.0) : 0.0;
    final overGoal = count > goal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cigarettes today', style: theme.textTheme.bodyLarge),
                Text(
                  '$count / $goal goal',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: overGoal ? colorScheme.error : colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(8),
              minHeight: 8,
              color: overGoal ? colorScheme.error : colorScheme.primary,
            ),
            if (overGoal) ...[
              const SizedBox(height: 8),
              Text(
                "You've exceeded today's goal. Tomorrow is a new chance!",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onLog,
              icon: const Icon(Icons.add),
              label: const Text('Log a cigarette'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.tip,
    required this.colorScheme,
    required this.theme,
  });

  final String tip;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

