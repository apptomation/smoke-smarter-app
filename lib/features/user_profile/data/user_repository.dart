import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smoke_smarter_app/features/user_profile/data/user_profile.dart';

class UserRepository {
  UserRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Streams the user profile document — emits null if the doc doesn't exist yet.
  Stream<UserProfile?> watchProfile(String uid) {
    return _doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserProfile.fromMap(uid, snap.data()!);
    });
  }

  /// Creates or updates the interests field (merge keeps other fields intact).
  Future<void> saveInterests(String uid, List<String> interests) {
    return _doc(uid).set(
      {'interests': interests},
      SetOptions(merge: true),
    );
  }
}
