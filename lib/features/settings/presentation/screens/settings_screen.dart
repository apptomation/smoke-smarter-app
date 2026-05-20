import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smoke_smarter_app/features/auth/providers/auth_providers.dart';
import 'package:smoke_smarter_app/features/user_profile/providers/user_profile_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;
  int? _dailyGoal; // null until profile loaded
  bool _initialized = false;

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  Future<void> _updateGoal(int newGoal) async {
    setState(() => _dailyGoal = newGoal);
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    await ref.read(userRepositoryProvider).updateDailyGoal(uid, newGoal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Load goal from Firestore profile once
    final profile = ref.watch(userProfileProvider).valueOrNull;
    if (!_initialized && profile?.cigarettesPerDay != null) {
      _dailyGoal = profile!.cigarettesPerDay!;
      _initialized = true;
    }
    final goal = _dailyGoal ?? profile?.cigarettesPerDay ?? 10;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Profile section
          _SectionHeader(label: 'Profile', theme: theme),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: const Text('Your Name'),
                  subtitle: const Text('Tap to edit profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(
                    Icons.interests_rounded,
                    color: colorScheme.primary,
                  ),
                  title: const Text('My Interests'),
                  subtitle: const Text('Add or update your interests'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/interests/edit'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Preferences
          _SectionHeader(label: 'Preferences', theme: theme),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                  secondary: Icon(
                    Icons.notifications_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Notifications'),
                  subtitle: const Text('Reminders & motivational nudges'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                  secondary: Icon(
                    Icons.dark_mode_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Dark mode'),
                  subtitle: const Text('Override system theme'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(
                    Icons.flag_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Daily cigarette goal'),
                  subtitle: Text('$goal cigarettes/day'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: goal > 1
                            ? () => _updateGoal(goal - 1)
                            : null,
                      ),
                      Text(
                        '$goal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _updateGoal(goal + 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About
          _SectionHeader(label: 'About', theme: theme),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: colorScheme.primary),
                  title: const Text('App version'),
                  trailing: Text(
                    '1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(
                    Icons.privacy_tip_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Privacy policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sign out
          Card(
            color: colorScheme.errorContainer,
            child: ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: colorScheme.onErrorContainer,
              ),
              title: Text(
                'Sign out',
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _confirmLogout,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.theme});

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
