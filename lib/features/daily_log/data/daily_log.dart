class DailyLog {
  const DailyLog({
    required this.date,
    required this.count,
    required this.goal,
  });

  /// The date this log belongs to (YYYY-MM-DD, no time component)
  final DateTime date;

  /// Number of cigarettes smoked on this day
  final int count;

  /// Daily goal on this day
  final int goal;

  bool get isUnderGoal => count <= goal;

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  factory DailyLog.fromMap(Map<String, dynamic> data) {
    return DailyLog(
      date: DateTime.parse(data['date'] as String),
      count: (data['count'] as num?)?.toInt() ?? 0,
      goal: (data['goal'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'date': dateKey,
        'count': count,
        'goal': goal,
      };
}
