import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smoke_smarter_app/features/auth/providers/auth_providers.dart';
import 'package:smoke_smarter_app/features/user_profile/providers/user_profile_providers.dart';

// ── Interest catalogue ────────────────────────────────────────────────────────

class _Interest {
  const _Interest({required this.label, required this.emoji});
  final String label;
  final String emoji;
}

const _allInterests = [
  _Interest(label: 'Technology', emoji: '💻'),
  _Interest(label: 'Sports', emoji: '⚽'),
  _Interest(label: 'Music', emoji: '🎵'),
  _Interest(label: 'Health', emoji: '❤️'),
  _Interest(label: 'Cooking', emoji: '🍳'),
  _Interest(label: 'Travel', emoji: '✈️'),
  _Interest(label: 'Art', emoji: '🎨'),
  _Interest(label: 'Reading', emoji: '📚'),
  _Interest(label: 'Gaming', emoji: '🎮'),
  _Interest(label: 'Nature', emoji: '🌿'),
  _Interest(label: 'Fitness', emoji: '💪'),
  _Interest(label: 'Photography', emoji: '📷'),
  _Interest(label: 'Fashion', emoji: '👗'),
  _Interest(label: 'Movies', emoji: '🎬'),
  _Interest(label: 'Science', emoji: '🔬'),
  _Interest(label: 'Mindfulness', emoji: '🧘'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key, this.isEditing = false});

  /// When true, shown from Settings — has a back button and saves back instead
  /// of navigating to dashboard.
  final bool isEditing;

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  final Set<String> _selected = {};
  bool _saving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Pre-populate with already-saved interests
      final saved = ref.read(userProfileProvider).valueOrNull?.interests ?? [];
      _selected.addAll(saved);
      _initialized = true;
    }
  }

  Future<void> _save() async {
    if (_selected.isEmpty) return;
    setState(() => _saving = true);

    try {
      final uid = ref.read(authStateProvider).valueOrNull?.uid;
      if (uid == null) return;

      await ref.read(userRepositoryProvider).saveInterests(
            uid,
            _selected.toList(),
          );

      if (!mounted) return;
      if (widget.isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interests updated!')),
        );
        context.pop();
      } else {
        context.go('/dashboard');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: widget.isEditing
          ? AppBar(title: const Text('My Interests'))
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(24, widget.isEditing ? 16 : 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isEditing) ...[  
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.interests_rounded,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    widget.isEditing ? 'Update your interests' : 'What are you\ninto?',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isEditing
                        ? 'Add or remove interests. At least one is required.'
                        : 'Pick at least one interest. We use this to personalize your experience.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Grid ────────────────────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.4,
                ),
                itemCount: _allInterests.length,
                itemBuilder: (context, i) {
                  final item = _allInterests[i];
                  final selected = _selected.contains(item.label);
                  return _InterestTile(
                    interest: item,
                    selected: selected,
                    onTap: () => setState(() {
                      selected
                          ? _selected.remove(item.label)
                          : _selected.add(item.label);
                    }),
                  );
                },
              ),
            ),

            // ── Footer ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  // Selection counter
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _selected.isNotEmpty ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${_selected.length} selected',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: (_selected.isEmpty || _saving) ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.isEditing ? 'Save changes' : 'Continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tile widget ───────────────────────────────────────────────────────────────

class _InterestTile extends StatelessWidget {
  const _InterestTile({
    required this.interest,
    required this.selected,
    required this.onTap,
  });

  final _Interest interest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(interest.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  interest.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded,
                    size: 18, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
