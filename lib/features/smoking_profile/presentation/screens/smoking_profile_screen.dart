import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smoke_smarter_app/features/auth/providers/auth_providers.dart';
import 'package:smoke_smarter_app/features/user_profile/providers/user_profile_providers.dart';

class SmokingProfileScreen extends ConsumerStatefulWidget {
  const SmokingProfileScreen({super.key});

  @override
  ConsumerState<SmokingProfileScreen> createState() =>
      _SmokingProfileScreenState();
}

class _SmokingProfileScreenState extends ConsumerState<SmokingProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cigarettesPerDayController = TextEditingController(text: '10');
  final _cigarettesPerPackController = TextEditingController(text: '20');
  final _pricePerPackController = TextEditingController();

  DateTime _quitStartDate = DateTime.now();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _cigarettesPerDayController.dispose();
    _cigarettesPerPackController.dispose();
    _pricePerPackController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _quitStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _quitStartDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final uid = ref.read(authStateProvider).valueOrNull?.uid;
      if (uid == null) throw Exception('Not logged in');

      final repo = ref.read(userRepositoryProvider);
      await repo.saveSmokingProfile(
        uid: uid,
        cigarettesPerDay: int.parse(_cigarettesPerDayController.text.trim()),
        cigarettesPerPack: int.parse(_cigarettesPerPackController.text.trim()),
        pricePerPack: double.parse(_pricePerPackController.text.trim()),
        quitStartDate: _quitStartDate,
      );

      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() => _error = 'Failed to save. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Set up your profile',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We need a few details to calculate your savings and track your progress.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),

                // Cigarettes per day
                _SectionLabel(label: 'How many cigarettes did you smoke per day?'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cigarettesPerDayController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Cigarettes per day',
                    hintText: 'e.g. 10',
                    suffixText: 'cigs',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Enter a number greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Cigarettes per pack
                _SectionLabel(label: 'How many cigarettes are in one pack?'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cigarettesPerPackController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Cigarettes per pack',
                    hintText: 'e.g. 20',
                    suffixText: 'cigs',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Enter a number greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Price per pack
                _SectionLabel(label: 'How much does one pack cost?'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pricePerPackController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Price per pack',
                    hintText: 'e.g. 8.50',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Enter a valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Quit start date
                _SectionLabel(label: 'When did you start your journey?'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      '${_quitStartDate.day.toString().padLeft(2, '0')}/'
                      '${_quitStartDate.month.toString().padLeft(2, '0')}/'
                      '${_quitStartDate.year}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: colorScheme.onErrorContainer),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
