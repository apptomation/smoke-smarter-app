import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smoke_smarter_app/features/auth/providers/auth_providers.dart';
import 'package:smoke_smarter_app/features/daily_log/data/daily_log.dart';
import 'package:smoke_smarter_app/features/daily_log/data/log_repository.dart';
import 'package:smoke_smarter_app/features/user_profile/providers/user_profile_providers.dart';

final logRepositoryProvider = Provider<LogRepository>(
  (ref) => LogRepository(ref.watch(firestoreProvider)),
);

/// Streams today's log for the current user.
final todayLogProvider = StreamProvider<DailyLog?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref.watch(logRepositoryProvider).watchTodayLog(user.uid);
});

/// Streams stats calculated from logs since quit start date — updates in real-time.
final dashboardStatsProvider = StreamProvider<DashboardStats?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);

  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile == null || !profile.hasSmokingProfile) return Stream.value(null);

  final quitStart = profile.quitStartDate!;
  return ref
      .watch(logRepositoryProvider)
      .watchLogsSince(user.uid, quitStart)
      .map((logs) {

  final logMap = {for (final l in logs) l.dateKey: l};

  // Streak: consecutive days from today backwards where count <= goal
  int streak = 0;
  final today = DateTime.now();
  for (int i = 0; i < 365; i++) {
    final day = today.subtract(Duration(days: i));
    final key =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final log = logMap[key];
    // A day with no log entry counts as 0 smoked (good)
    final count = log?.count ?? 0;
    final goal = log?.goal ?? profile.cigarettesPerDay!;
    if (count <= goal) {
      streak++;
    } else {
      break;
    }
  }

  // Money saved: (would have smoked - actually smoked) × price per cigarette
  final daysSinceStart = today.difference(quitStart).inDays + 1;
  final totalWouldHaveSmoked = daysSinceStart * profile.cigarettesPerDay!;
  final totalActuallySmoked = logs.fold<int>(0, (sum, l) => sum + l.count);
  final cigarettesNotSmoked = (totalWouldHaveSmoked - totalActuallySmoked)
      .clamp(0, totalWouldHaveSmoked);
  final moneySaved =
      cigarettesNotSmoked.toDouble() * (profile.pricePerCigarette ?? 0);

  // Health score: weighted mix of days smoke-free and reduction %
  final smokeFreedays = logs.where((l) => l.count == 0).length +
      (daysSinceStart - logs.length).clamp(0, daysSinceStart);
  final reductionPct = totalWouldHaveSmoked > 0
      ? (cigarettesNotSmoked / totalWouldHaveSmoked * 100).clamp(0, 100)
      : 0.0;
  final healthScore = ((smokeFreedays / daysSinceStart * 50) +
          (reductionPct * 0.5))
      .clamp(0.0, 100.0)
      .round();

        return DashboardStats(
          streak: streak,
          moneySaved: moneySaved,
          healthScore: healthScore,
        );
      });
});

/// Streams the last 7 days of logs for the current user — updates in real-time.
final weeklyLogsProvider = StreamProvider<List<DailyLog>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  final since = DateTime.now().subtract(const Duration(days: 6));
  return ref.watch(logRepositoryProvider).watchLogsSince(user.uid, since);
});

class DashboardStats {
  const DashboardStats({
    required this.streak,
    required this.moneySaved,
    required this.healthScore,
  });

  final int streak;
  final double moneySaved;
  final int healthScore;
}
