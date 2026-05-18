class UserProfile {
  const UserProfile({
    required this.uid,
    required this.interests,
  });

  final String uid;
  final List<String> interests;

  bool get hasInterests => interests.isNotEmpty;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      interests: List<String>.from(data['interests'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {'interests': interests};
}
