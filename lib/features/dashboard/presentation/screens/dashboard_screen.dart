import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Good morning 👋'),
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
          _StreakCard(colorScheme: colorScheme, theme: theme),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.attach_money_rounded,
                  label: 'Money saved',
                  value: '\$124',
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.favorite_rounded,
                  label: 'Health score',
                  value: '78%',
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
          _TodayLogCard(colorScheme: colorScheme, theme: theme),
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
            tip: 'When you feel a craving, try the 4-7-8 breathing technique — inhale for 4 seconds, hold for 7, exhale for 8.',
            colorScheme: colorScheme,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.colorScheme, required this.theme});

  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
                Text(
                  '7 days smoke-free',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep it up! You\'re doing amazing.',
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
                Text(
                  '🔥',
                  style: const TextStyle(fontSize: 28),
                ),
                Text(
                  '7',
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
  const _TodayLogCard({required this.colorScheme, required this.theme});

  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cigarettes today',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  '2 / 5 goal',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 2 / 5,
              borderRadius: BorderRadius.circular(8),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () {},
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
