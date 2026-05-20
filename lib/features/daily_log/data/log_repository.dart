import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smoke_smarter_app/features/daily_log/data/daily_log.dart';

class LogRepository {
  LogRepository(this._firestore);

  final FirebaseFirestore _firestore;

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DocumentReference<Map<String, dynamic>> _logDoc(String uid, String dateKey) =>
      _firestore.collection('users').doc(uid).collection('logs').doc(dateKey);

  /// Streams today's log document. Emits null if no log exists yet today.
  Stream<DailyLog?> watchTodayLog(String uid) {
    final key = _dateKey(DateTime.now());
    return _logDoc(uid, key).snapshots().map((snap) {
      if (!snap.exists) return null;
      return DailyLog.fromMap(snap.data()!);
    });
  }

  /// Atomically increments today's cigarette count by 1.
  /// Creates the document if it doesn't exist yet.
  Future<void> logCigarette(String uid, {required int goal}) async {
    final key = _dateKey(DateTime.now());
    final ref = _logDoc(uid, key);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(ref, {'date': key, 'count': 1, 'goal': goal});
      } else {
        final current = (snap.data()!['count'] as num?)?.toInt() ?? 0;
        tx.update(ref, {'count': current + 1, 'goal': goal});
      }
    });
  }

  /// Fetches all log documents from [since] up to today.
  /// Used for streak and stats calculations.
  Future<List<DailyLog>> fetchLogsSince(String uid, DateTime since) async {
    final sinceKey = _dateKey(since);
    final todayKey = _dateKey(DateTime.now());
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('logs')
        .where('date', isGreaterThanOrEqualTo: sinceKey)
        .where('date', isLessThanOrEqualTo: todayKey)
        .get();
    return snap.docs.map((d) => DailyLog.fromMap(d.data())).toList();
  }

  /// Streams log documents from [since] up to today — updates in real-time.
  Stream<List<DailyLog>> watchLogsSince(String uid, DateTime since) {
    final sinceKey = _dateKey(since);
    final todayKey = _dateKey(DateTime.now());
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('logs')
        .where('date', isGreaterThanOrEqualTo: sinceKey)
        .where('date', isLessThanOrEqualTo: todayKey)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DailyLog.fromMap(d.data())).toList());
  }
}
